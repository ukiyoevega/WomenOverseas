//
//  LoginView.swift
//  WMO
//
//  Created by weijia on 2022/4/22.
//

import SwiftUI
import Foundation

struct LoginView: View {
    @State private var showWebView = false
    @State private var isChecked = false
    
    var body: some View {
        ZStack {
            if #available(iOS 14, *) {
                Color.accentBackground.ignoresSafeArea()
            } else {
                Color.accentBackground.edgesIgnoringSafeArea(.all)
            }
            VStack(alignment: .center, spacing: 6) {
                Image("login_background", bundle: nil)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("探索广阔的世界，成为更好的自己")
                    .font(.system(size: 30, weight: .regular))
                    .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                    .foregroundColor(.black.opacity(0.65))
                Text("进入她乡")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .background(
                        Color.accentForeground
                            .frame(width: 343, height: 52)
                            .cornerRadius(20)
                    )
                    .onTapGesture {
                        showWebView.toggle()
                    }
                    .padding(20)
                    .sheet(isPresented: $showWebView) {
                        let request = ApiKeyRequest()
                        if let url = try? request.absoluteURL(), let secKey = request.keyPair {
                            Webview(type: .home, url: url.absoluteString, secKey: secKey)
                        }
                    }
                /*
                 HStack(spacing: 2) {
                 Button {
                 isChecked.toggle()
                 } label: {
                 Image(systemName: isChecked ? "checkmark.circle.fill" : "checkmark.circle").foregroundColor(.black.opacity(0.45))
                 .imageScale(.small)
                 }
                 AttributedText(ns_agreementAndPolicy)
                 }
                 */
            }
        }
    }
    
    var ns_agreementAndPolicy: NSAttributedString {
        let mutableText = NSMutableAttributedString(string: "我已阅读并同意用户协议和隐私政策", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.black.withAlphaComponent(0.45),
        ])
        let text = mutableText.string as NSString
        let agreementRange = text.range(of: "用户协议")
        let policyRange = text.range(of: "隐私政策")
        if agreementRange.length > 0, policyRange.length > 0,
           let agreementURL = URL(string: "https://womenoverseas.com/tos"),
           let policyURL = URL(string: "https://womenoverseas.com/privacy") {
            mutableText.addAttributes([
                NSAttributedString.Key.link : agreementURL,
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ], range: agreementRange)
            mutableText.addAttributes([
                NSAttributedString.Key.link : policyURL,
                NSAttributedString.Key.foregroundColor: UIColor.black,
            ], range: policyRange)
        }
        return mutableText
    }
}

private struct AttributedText: UIViewRepresentable {
    var attributedText: NSAttributedString

    init(_ attributedText: NSAttributedString) {
        self.attributedText = attributedText
    }

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        label.attributedText = attributedText
        label.sizeToFit()
    }
}

#if DEBUG
struct SigninView_Previews : PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
