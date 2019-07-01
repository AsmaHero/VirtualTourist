//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Asmahero on ١٥ شوال، ١٤٤٠ هـ.
//  Copyright © ١٤٤٠ هـ Asmahero. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
let dataController = DataController(modelName: "VTDB")
    func checkIfFirstLaunchApp(){
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore"){
         //   print("app has launched before")
        }else {
        //    print ("This is first launch")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.synchronize()
        }
    }
    // MARK: UIApplicationDelegate
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Usually this is not overridden. Using the "did finish launching" method is more typical
       // print("App Delegate: will finish launching")
        checkIfFirstLaunchApp()
        return true
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        // passing data controller value to othe VC
        // all lines below until before return true to assign data controller to that MapTravelVC, before we declare datacontroller in that view controller.
        // call the navigation controller before MapTravelVC
        let navController = window?.rootViewController as! UINavigationController
        // to say that notebooklistVC on the top of that navController
        let pinlistVC =  navController.topViewController as! MapTravelVC
        pinlistVC .dataController = dataController
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }
    func saveViewContext(){
        try? dataController.viewContext.save()
    }


}

