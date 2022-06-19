//
//  AppDelegate.swift
//  WMO
//
//  Created by weijia on 2022/4/23.
//

/* Regex Search https://jayeshkawli.ghost.io/search-and-replace-in-xcode-with-regular-expressions/
 start with ": " and end with ",
 -> "\: .*",$
 
 start with ": Number and end with ,
 -> "\: [^0-9],$
 
 start with ": Number and end with false,
 "\: false,$
 
 case sameString = "sameString"
 find: case (.*) = \"[^_]*$
 replacing: case (.*) = \"([^_]*)"$

 : \132
 : \d
 */

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
            let tabview = TabBarView(selectedTab: .latest, link: url)
            self.window?.rootViewController = UIHostingController(rootView: tabview)
            return true
        }
        return false
    }
}
/*
 Option 1: unidirectional flow of control
 Presenter -> ViewController -> Interactor
 
 SwiftUI: single source of truth
 View.body would be called upon @Published(nested in @State，@ObservedObject) change
 
 ↓
 
 WithViewStore:
    convert pure-data driven `Store` into SwiftUI measurable data, can construct View.body
    this view(WithViewStore) own a `ViewStore` type internally to stay reference to `store`
    as a view, it use `@ObservedObject` to observe its `ViewStore` and respond upon change
 
 Effect:
    `Effect` is when we need to make additional operation while handling `Action`, and trasform the result into another `Action`
 */
