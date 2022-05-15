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
        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = UIHostingController(rootView:
            LoginView()
        )
        window.rootViewController = controller
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        print("UIApplication willContinueUserActivityWithType userActivityType \(userActivityType)")
        return true
    }
    
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("UIApplication didUpdate userActivity \(userActivity)")
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print("UIApplication didFailToContinueUserActivityWithType \(error)")
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("UIApplication continue userActivity \(userActivity)")
        if let url = userActivity.webpageURL?.path {
            print("continue userActivity \(url)")
            let tabview = TabbarView(tab: .latest, link: url).accentColor(Color("button_pink", bundle: nil))
            self.window?.rootViewController = UIHostingController(rootView: tabview)
            return true
        }
        return false
    }
}
