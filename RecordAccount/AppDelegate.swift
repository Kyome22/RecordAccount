//
//  AppDelegate.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/22.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let userDefaults = UserDefaults.standard

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		setStatusBarBackgroundColor(color: UIColor(hex: "CFD8DC"))
		userDefaults.register(defaults: ["first" : true])
		if userDefaults.bool(forKey: "first") {
			if let vc = self.window?.rootViewController as? RAMAnimatedTabBarController {
				vc.selectedIndex = 2
				vc.setSelectIndex(from: 0, to: 2)
				userDefaults.set(false, forKey: "first")
			}
		}
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {

	}

	func applicationDidEnterBackground(_ application: UIApplication) {

	}

	func applicationWillEnterForeground(_ application: UIApplication) {

	}

	func applicationDidBecomeActive(_ application: UIApplication) {

	}

	func applicationWillTerminate(_ application: UIApplication) {

	}

	func setStatusBarBackgroundColor(color: UIColor) {
		UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
		guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
		statusBar.backgroundColor = color
	}

}

