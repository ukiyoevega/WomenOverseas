//
//  WebView.swift
//  WMO
//
//  Created by weijia on 2022/4/23.
//

import SwiftUI
import WebKit
import CryptoKit

struct Webview: UIViewControllerRepresentable {
    let url: URL
    let sedKey: SecKey?
    
    func makeUIViewController(context: Context) -> WebviewController {
        let webviewController = WebviewController(seckKey: self.sedKey)
        var urlRequest = URLRequest(url: self.url)
        if !APIService.shared.apiKey.isEmpty {
            urlRequest.setValue(APIService.shared.apiKey, forHTTPHeaderField: "user-api-key")
        }
        webviewController.webview.load(urlRequest)
        return webviewController
    }
    
    func updateUIViewController(_ webviewController: WebviewController, context: Context) {}
}

class WebviewController: UIViewController {
    private let secKey: SecKey?
    lazy public var webview: WKWebView = WKWebView()
    lazy private var progressbar: UIProgressView = UIProgressView()
    
    init(seckKey: SecKey?) {
        self.secKey = seckKey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        //        webview.removeObserver(self, forKeyPath: "estimatedProgress")
        //        webview.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.navigationDelegate = self
        view.addSubview(webview)
        
        webview.frame = self.view.frame
        webview.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints([
            webview.topAnchor.constraint(equalTo: self.view.topAnchor),
            webview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        webview.addSubview(self.progressbar)
        self.setProgressBarPosition()
        
                webview.scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        
        self.progressbar.progress = 0.1
//        webview.observe(\.estimatedProgress) { [weak self] webview, changed in
//            print("WKWebView estiamted Progress \(webview.estimatedProgress)")
//            self?.progressbar.progress = Float(webview.estimatedProgress)
//        }
                webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    func setProgressBarPosition() {
        self.progressbar.translatesAutoresizingMaskIntoConstraints = false
        webview.removeConstraints(webview.constraints)
        webview.addConstraints([
            self.progressbar.topAnchor.constraint(equalTo: webview.topAnchor, constant: webview.scrollView.contentOffset.y * -1),
            self.progressbar.leadingAnchor.constraint(equalTo: webview.leadingAnchor),
            self.progressbar.trailingAnchor.constraint(equalTo: webview.trailingAnchor),
        ])
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "estimatedProgress":
            if webview.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, animations: { () in
                    self.progressbar.alpha = 0.0
                }, completion: { finished in
                    self.progressbar.setProgress(0.0, animated: false)
                })
            } else {
                self.progressbar.isHidden = false
                self.progressbar.alpha = 1.0
                progressbar.setProgress(Float(webview.estimatedProgress), animated: true)
            }

        case "contentOffset":
            self.setProgressBarPosition()

        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension WebviewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = webView.url, let secKey = self.secKey,
           let components = URLComponents(string: url.absoluteString),
           let payload = components.queryItems?.first(where: { $0.name == "payload" })?.value {
            do {
                let trimmedPayload = String(payload.filter { !" \n".contains($0) })
                let decryptedJsonString = try decrypted(rawData: trimmedPayload, with: secKey, algorithm: .rsaEncryptionPKCS1)
                APIService.shared.apiKey = decryptedJsonString["key"] as? String ?? ""
            } catch {
                print(error) // TODO: error handling
            }
        }
        if let navigationScheme = navigationAction.request.url?.scheme, ["http", "https"].contains(navigationScheme) {
            return decisionHandler(.allow)
        }
        decisionHandler(.cancel) // dismiss if payload decrypted
        self.dismiss(animated: true) {
            self.routeToTab()
        }
    }
    
    func routeToTab() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }
        let tabview = TabbarView().accentColor(Color("button_pink", bundle: nil))
        sceneDelegate.window?.rootViewController = UIHostingController(rootView: tabview)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
