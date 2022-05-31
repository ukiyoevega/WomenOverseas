//
//  SceneDelegate.swift
//  WMO
//
//  Created by weijia on 2022/4/23.
//

import UIKit
import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
        
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = LoginView()
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let key = APIService.shared.apiKey
            if key.isEmpty {
                window.rootViewController = UIHostingController(rootView: contentView)
            } else {
                let tab = TabBarView(selectedTab: .home, link: nil).accentColor(Color.accentForeground)
                window.rootViewController = UIHostingController(rootView: tab)
            }
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let url = userActivity.webpageURL, url.path.contains("topic") {
            let tabview = TabBarView(selectedTab: .latest, link: url.absoluteString).accentColor(Color.accentForeground)
            self.window?.rootViewController = UIHostingController(rootView: tabview)
        }
    }
}
