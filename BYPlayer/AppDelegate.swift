//
//  AppDelegate.swift
//  BYPlayer
//
//  Created by 王腾飞 on 2020/3/19.
//  Copyright © 2020 王腾飞. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let rootVC = BYMediaViewController()
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.white
        let nav = UINavigationController.init(rootViewController: rootVC)

        self.window?.rootViewController = nav
        return true
    }

   

}

