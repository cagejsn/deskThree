    //
//  AppDelegate.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import SlideMenuControllerSwift
import Zip

#if !DEBUG
import Mixpanel
#endif
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dvc: DeskViewController!
    
    #if !DEBUG
    var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif
   
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        
        print(Zip.isValidFileExtension("edf"))
        Zip.addCustomFileExtension("edf")
        print(Zip.isValidFileExtension("edf"))
        
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        #if !DEBUG
            mixpanel.track(event: "App Opened")
        #endif
        
        dvc = DeskViewController()
        let hmc = HamburgerMenuViewController()
        hmc.delegate = dvc  
        
        SlideMenuOptions.leftViewWidth = 367
      //  SlideMenuOptions.leftBezelWidth = 100
        SlideMenuOptions.contentViewDrag = true
        SlideMenuOptions.contentViewOpacity = 0.2
        SlideMenuOptions.panGesturesEnabled = false
        
        let slideMenuController = SlideMenuController(mainViewController: dvc, leftMenuViewController: hmc, rightMenuViewController: UIViewController())
        self.window?.rootViewController = slideMenuController
        
        self.window?.makeKeyAndVisible()
        let isFirstLaunch = UserDefaults.isFirstLaunch()
        if isFirstLaunch {
            let tutorialVideoViewController = TutorialVideoViewController()
            slideMenuController.present(tutorialVideoViewController, animated: true, completion: nil)
        }
        
        Fabric.with([Crashlytics.self])
        
        
        
        return true
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

        #if !DEBUG
            Mixpanel.mainInstance().people.increment(property: "Times app launched", by: 1)
        #endif
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        #if !DEBUG
            Mixpanel.mainInstance().people.increment(property: "Times app terminated", by: 1)
        #endif
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        Zip.addCustomFileExtension("edf")
        
        var fileNameWithType = url.lastPathComponent
        if !fileNameWithType.contains(".edf") {
            return false
        }
        
        
        let substringIndex = fileNameWithType.index(fileNameWithType.endIndex, offsetBy: -4)
        let fileName = fileNameWithType.substring(to: substringIndex )
        
        var sharedGrouping = MetaDataInteractor.getSharedWithMeGrouping()
        var project = DeskProject(name: fileName)
        
        let change = MetaChange.CreatedProject
        try! FileSystemInteractor.handleMeta(change, grouping: &sharedGrouping, project: &project)
        
        let groupingsFolder = PathLocator.getProjectsFolderFor(groupingName: sharedGrouping.getName())
        let newPath = URL(fileURLWithPath: groupingsFolder + "/" + fileNameWithType)
        
        let fileManager = FileManager.default
        try! fileManager.moveItem(at: url, to: newPath)

        dvc.didSelectProject(grouping: sharedGrouping, project: project)
        try? fileManager.removeItem(at: url)
        return true
    }
    
    
    //TODO: Known issues with opening sent files.
    //1. the name of the project (inside the zip file)
    // and the name of the zipped file have to be the same, or else crash
    //2. there can't be a zipped file with the same name at the grouping's project folder
    // level, or else fileManager.moveItem will crash
    //3. the grouping can't have a project in it with the same name, or else it will change the name of the project it creates to *whatever*(2) and the project name wont match the zipped file name

}

