//
//  AppDelegate.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/6/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator
import FacebookCore
import RealmSwift
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var unsafeWindow: UIWindow {
        return AppDelegate.shared.window!
    }
    
    let navigator = AppNavigator()
    
    static var shared: AppDelegate {
        return (UIApplication.sharedApplication().delegate as! AppDelegate)
    }
    
    func clearRealmIfMigrationIsNeeded() {
        do {
            let _ = try Realm()
        } catch _ {
            deleteDefaultRealmFile()
        }
    }
    
    func deleteDefaultRealmFile() {
        if let file = Realm.Configuration.defaultConfiguration.fileURL {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(file)
                print("Realm deleted.")
            } catch let error {
                print("Cannot delete default Realm file:\n\(error).")
            }
            
        } else {
            print("No default file url.")
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])

        print("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!.absoluteString)")
        clearRealmIfMigrationIsNeeded()
        
        FacebookCore.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let window = window {
            window.backgroundColor = UIColor.whiteColor()
            
            navigator.onAppLaunch()
            
            window.makeKeyAndVisible()
        }
        
        NetworkActivityIndicatorManager.sharedManager.isEnabled = true
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let handled = FacebookCore.ApplicationDelegate.shared.application(app, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey] ?? [])
        
        self.navigator.didLoginWithFacebook()
        
        return handled
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let user = User.users.first {
            user.updateMyActive(false).start()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if let user = User.users.first {
            user.updateMyActive(true).start()
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)
        if let user = User.users.first {
            user.updateMyActive(true).start()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if let user = User.users.first {
            user.updateMyActive(false).start()
        }
    }


}

