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
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
                
//        AppUserDefaults.shared.numberOfLaunch += 1
//        if AppUserDefaults.shared.numberOfLaunch == 3 {
//            SKStoreReviewController.requestReview()
//        }
    }

}
