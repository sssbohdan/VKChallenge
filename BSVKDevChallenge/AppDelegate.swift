//
//  AppDelegate.swift
//  BSVKDevChallenge
//
//  Created by bbb on 11/9/18.
//  Copyright © 2018 bbb. All rights reserved.
//

import UIKit
import VK_ios_sdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.configure()
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        VKSdk.processOpen(url, fromApplication: options[.sourceApplication] as? String)
        return true
    }
}

private extension AppDelegate {
    func configure() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainController = ControllerInitializer.getFeedViewController()
        let navigation = UINavigationController(rootViewController: mainController)
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
    }
}
