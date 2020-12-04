//
//  AppDelegate.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 04/02/2016.
//  Copyright (c) 2016 Max Baumbach. All rights reserved.
//

import RBSRealmBrowser
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { fatalError("Failed to get a window") }
        window.backgroundColor = UIColor.white
        
        let initialViewController = ViewController()
        
        let navigationController = UINavigationController(rootViewController: initialViewController)
        navigationController.navigationBar.tintColor = .black
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        window.rootViewController = navigationController
        // add the realmbrowser quick action to your shortcut items array
        if #available(iOS 9.0, *) {
            application.shortcutItems = [RBSRealmBrowser.addBrowserQuickAction()]
        } else {
            // Fallback on earlier versions
        }
        window.makeKeyAndVisible()
        return true
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        
        // handle the quick action
        let realmBrowser: UIViewController = RBSRealmBrowser.realmBrowser()!
        let viewController = (window?.rootViewController)! as UIViewController
        viewController.present(realmBrowser, animated: true)
        
    }
}
