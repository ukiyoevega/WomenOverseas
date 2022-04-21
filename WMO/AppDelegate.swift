//
//  AppDelegate.swift
//  WMO
//
//  Created by weijia on 2022/4/23.
//

import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        UIApplication.shared.registerForRemoteNotifications()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = UIHostingController(rootView:
            LoginView()
        )
        window.rootViewController = controller
        self.window = window
        window.makeKeyAndVisible()
        print("Your code here")
        return true
    }

    // MARK: UISceneSession Lifecycle
//    func application(_ application: UIApplication,
//                     configurationForConnecting connectingSceneSession: UISceneSession,
//                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        
//    }
}

//
//@available(iOS 14.0, macOS 10.16, *)
//@main
//struct MainView: App {
//
//    init() {
//        setupApperance()
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            LoginView()
//        }
//    }
//
//    private func setupApperance() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.red,
//                                                                 .font: UIFont.systemFont(ofSize: 40)]
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.green,
//                                                            .font: UIFont.systemFont(ofSize: 18)]
//        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.blue,
//                                                             .font: UIFont.systemFont(ofSize: 16)], for: .normal)
//        UIWindow.appearance().tintColor = UIColor.systemPink
//    }
//}
//
