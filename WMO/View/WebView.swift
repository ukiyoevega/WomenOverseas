//
//  WebView.swift
//  WMO
//
//  Created by weijia on 2022/4/23.
//

import SwiftUI
import WebKit
import CryptoKit

private let refConLength: CGFloat = 50
private let refDropHeight: CGFloat = 70

enum NavigationDirection {
  case none
  case back(id: String)
  case forward(id: String)
}

struct Webview: View {
  let type: Tab
  let url: String
  let secKey: SecKey?
  @State var navigationDirection: NavigationDirection = .none

  var body: some View {
    WebViewControllerRepresentable(type: type, url: url, secKey: secKey, navDirection: $navigationDirection)
      .navigationBarBackButtonHidden()
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            self.navigationDirection = .back(id: UUID().uuidString)
          } label: {
            Image(systemName: "chevron.left")
              .font(.system(size: 15, weight: .medium))
              .foregroundColor(Color.mainIcon)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            self.navigationDirection = .forward(id: UUID().uuidString)
          } label: {
            Image(systemName: "chevron.right")
              .font(.system(size: 15, weight: .medium))
              .foregroundColor(Color.mainIcon)
          }
        }
      }
  }
}

struct WebViewControllerRepresentable: UIViewControllerRepresentable {

  let type: Tab
  let url: String
  let secKey: SecKey?
  @Binding var navDirection: NavigationDirection
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  func makeUIViewController(context: Context) -> WebviewController {
    let webviewController = WebviewController(seckKey: self.secKey, type: type, preloadLatest: false)
    let URL = URL(string: self.url) ?? URL(string: "https://womenoverseas.com")!
    var urlRequest = URLRequest(url: URL)
    if !APIService.shared.apiKey.isEmpty {
      urlRequest.setValue(APIService.shared.apiKey, forHTTPHeaderField: "user-api-key")
    }
    webviewController.webview.load(urlRequest)
    return webviewController
  }

  func updateUIViewController(_ webviewController: WebviewController, context: Context) {
    switch navDirection {
    case .none:
      break
    case .back:
      if webviewController.webview.canGoBack {
        webviewController.webview.goBack()
      } else {
        presentationMode.wrappedValue.dismiss()
      }
    case .forward:
      webviewController.webview.goForward()
    }
  }
}

class WebviewController: UIViewController {

  enum RemoveElement: String {
    case header = "d-header-wrap"
    case tabbar = "d-tab-bar"
    case button = "btn-primary sign-up-button btn btn-text ember-view"
  }

  private let secKey: SecKey?
  private let type: Tab
  private let refreshControl = UIRefreshControl()
  private var webViewTopConstraint: NSLayoutConstraint?

  lazy public var webview: WKWebView = WKWebView()
  lazy private var progressbar: UIProgressView = UIProgressView()

  init(seckKey: SecKey?, type: Tab, preloadLatest: Bool = false) {
    self.secKey = seckKey
    self.type = type
    super.init(nibName: nil, bundle: nil)
    if preloadLatest, let url = URL(string: "https://womenoverseas.com/latest") {
      self.webview.load(URLRequest(url: url))
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var estimatedProgressObserve: NSKeyValueObservation?
  private var conentOffsetObserve: NSKeyValueObservation?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupSubviews()
    setupObservers()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if let path = webview.url?.path, path == "/login" {
      APIService.removeCache()
    }
  }

  @objc func back() {
    webview.goBack()
  }

  private func setupSubviews() {
    view.addSubview(webview)
    webview.backgroundColor = .white
    webview.frame = view.frame
    webview.navigationDelegate = self
    webview.allowsBackForwardNavigationGestures = true
    webview.scrollView.showsHorizontalScrollIndicator = false
    webview.scrollView.contentSize = view.bounds.size
    webview.scrollView.delegate = self
    webview.addSubview(self.progressbar)
    progressbar.progress = 0.1
    setProgressBarPosition()
  }

  private func setupObservers() {
    estimatedProgressObserve = webview.observe(\.estimatedProgress, options: .new) { [weak self] webview, changed in
      guard let self = self, let value = changed.newValue else { return }
      if value >= 1.0 {
        UIView.animate(withDuration: 0.3, animations: { () in
          self.progressbar.alpha = 0.0
        }, completion: { finished in
          self.progressbar.setProgress(0.0, animated: false)
        })
      } else {
        self.progressbar.isHidden = false
        self.progressbar.alpha = 1.0
        self.progressbar.setProgress(Float(value), animated: true)
      }
    }
    conentOffsetObserve = webview.scrollView.observe(\.contentOffset, options: .new) { [weak self] scrollView, changed in
      self?.setProgressBarPosition()
    }
    NotificationCenter.default.addObserver(forName: .triggerScrollToTopAndRefresh, object: nil, queue: .main) { [weak self] noti in
      guard let triggeredTab = noti.userInfo?["tab"] as? Tab, triggeredTab == self?.type else { return }
      self?.refreshControl.endRefreshing()
      self?.webview.scrollView.setContentOffset(CGPoint(x: 0, y: -refDropHeight), animated: true)
    }
  }

  @objc private func pullToRefresh() {
    webview.reload()
    refreshControl.endRefreshing()
  }

  private func setProgressBarPosition() {
    self.progressbar.translatesAutoresizingMaskIntoConstraints = false
    webview.removeConstraints(webview.constraints)
    webview.addConstraints([
      self.progressbar.topAnchor.constraint(equalTo: webview.topAnchor, constant: webview.scrollView.contentOffset.y * -1),
      self.progressbar.leadingAnchor.constraint(equalTo: webview.leadingAnchor),
      self.progressbar.trailingAnchor.constraint(equalTo: webview.trailingAnchor),
    ])
  }
}

extension WebviewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (scrollView.contentOffset.x > 0) {
      scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
    }
  }
}

extension WebviewController: WKNavigationDelegate {

  func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
    if let urlResponse = navigationResponse.response as? HTTPURLResponse, let username = urlResponse.allHeaderFields["x-discourse-username"] {
      if let utfData = (username as? String)?.data(using: .isoLatin1),
         let utf = String(data: utfData, encoding: .utf8) {
        UserDefaults.standard.set(utf, forKey: "com.womenoverseas.username")
        if utf == UserDefaults.standard.string(forKey: "com.womenoverseas.deletedAccount") {
          showRemovalAlert()
          return .cancel
        }
      } else {
        UserDefaults.standard.set(username, forKey: "com.womenoverseas.username")
      }
    }
    return .allow
  }

  private func showRemovalAlert() {
    let alertVC = UIAlertController(title: "注销提醒", message: "当前帐号申请了注销，无法继续登录。", preferredStyle: .alert)
    alertVC.addAction(UIAlertAction(title: "退出", style: .default) { action in
      self.dismiss(animated: true)
      APIService.removeCache()
    })
    present(alertVC, animated: true)
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    var payloadDecrypted = false
    if let url = webView.url, let secKey = self.secKey,
       let components = URLComponents(string: url.absoluteString),
       let payload = components.queryItems?.first(where: { $0.name == "payload" })?.value {
      do {
        let trimmedPayload = String(payload.filter { !" \n".contains($0) })
        let decryptedJsonString = try decrypted(rawData: trimmedPayload, with: secKey, algorithm: .rsaEncryptionPKCS1)
        APIService.shared.apiKey = decryptedJsonString["key"] as? String ?? ""
        payloadDecrypted = true
      } catch {
        print(error) // TODO: error handling
      }
    }
    decisionHandler(.allow)
    if payloadDecrypted { // dismiss if payload decrypted
      self.dismiss(animated: true) {
        self.routeToTab()
      }
    } else if let nextURL = navigationAction.request.url, nextURL.absoluteString != self.webview.url?.absoluteString {
      if nextURL.host == "womenoverseas.com" {
        webView.load(navigationAction.request)
      } else if canOpenHomePageBottomItems(nextURL) {
        UIApplication.shared.open(nextURL)
      }
    }
  }

  func canOpenHomePageBottomItems(_ url: URL) -> Bool {
    let bottomLinks = [
      "mailto:womenoverseas.taxiang@gmail.com",
      "https://blog.womenoverseas.com/",
      "https://mp.weixin.qq.com/s?__biz=MzAwMTMyNjA1Nw==&mid=2451850815&idx=1&sn=fe03c92f701f50306a513e9194ad2746&chksm=8d0b88b9ba7c01af2cda70bf1834ba68cd46892d640a7920bc3912fd1b64d57b5cbb56c65678&token=562956425&lang=zh_CN#rd",
      "https://www.xiaohongshu.com/user/profile/604595aa0000000001004db3?xhsshare=CopyLink&appuid=5ba493a1bcc119000128062f&apptime=1615355488",
      "https://pod.link/1549407631",
      "https://weibo.com/u/7574581372?refer_flag=1005055010_&is_all=1",
      "https://mp.weixin.qq.com/s/XqM5cdW_q0XeX7X-zXErYA",
      "https://t.me/womenoverseas",
      "https://pod.link/1549407631",
      "https://www.youtube.com/channel/UCFDELGqbjkz9v2vGM0d6HfA",
      "https://www.instagram.com/womenoverseas/"
    ]
    return bottomLinks.contains(url.absoluteString)
  }

  func routeToTab() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let sceneDelegate = windowScene.delegate as? SceneDelegate
    else {
      return
    }
    let tabview = TabBarView(selectedTab: .home, link: nil)
    sceneDelegate.window?.rootViewController = UIHostingController(rootView: tabview)
  }

  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
  }

  func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    print("🥹 ERROR \(error.localizedDescription)")
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    removeElement(.tabbar)
    if self.type == .home || self.type == .events {
      removeElement(.header)
    }
    removeElement(.button)
  }

  private func removeElement(_ type: RemoveElement) {
    let removeElementScript = "document.getElementsByClassName('\(type.rawValue)')[0].style.display='none';"
    // alternative: "document.querySelector('.\(type.rawValue)').style.display='none';"
    webview.evaluateJavaScript(removeElementScript) { (response, error) in
      if let error = error {
        print("🥹 ERROR \(error)")
      }
    }
  }

  private func decrypted(rawData: String, with key: SecKey, algorithm: SecKeyAlgorithm) throws -> [String: Any] {
    var error: Unmanaged<CFError>? = nil
    guard let data = Data(base64Encoded: rawData), let clearData = SecKeyCreateDecryptedData(key, .rsaEncryptionPKCS1, data as CFData, &error) else {
      let error = error?.takeRetainedValue() as Error?
      throw AppError.decryptAPIKeyFailed(error: error)
    }
    do {
      let serializedData = try JSONSerialization.jsonObject(with: clearData as Data, options: []) as? [String: Any]
      return serializedData ?? [:]
    } catch {
      throw error
    }
  }
}
