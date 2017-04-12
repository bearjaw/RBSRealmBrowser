//
//  AppDelegate.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 04/02/2016.
//  Copyright (c) 2016 Max Baumbach. All rights reserved.
//

import UIKit
import RBSRealmBrowser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var navigationController: UINavigationController?

     func applicationDidFinishLaunching(_ application: UIApplication) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        let initialViewController = ViewController()

        self.navigationController = UINavigationController(rootViewController: initialViewController)
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]

        self.window!.rootViewController = self.navigationController

        self.window!.tintColor = UIColor(colorLiteralRed: 0.714, green: 0.039, blue: 0.204, alpha: 1)
        // add the realmbrowser quick action to your shortcut items array
        if #available(iOS 9.0, *) {
            application.shortcutItems = [RBSRealmBrowser.addBrowserQuickAction()]
        } else {
            // Fallback on earlier versions
        }
        self.window!.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        // handle the quick action
        let rb:UIViewController = RBSRealmBrowser.realmBrowser()!
        let vc = (window?.rootViewController)! as UIViewController
        vc.present(rb, animated: true)
        
    }
    

}
