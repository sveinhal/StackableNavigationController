//
//  AppDelegate.swift
//  StackableNavigationController
//
//  Created by Svein Halvor Halvorsen on 21.06.15.
//  Copyright (c) 2015 Svein Halvor Halvorsen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        let navs = [nav]

        window?.rootViewController = StackableNavigationController(viewControllers: navs)
        window?.makeKeyAndVisible()

        return true
    }

}

