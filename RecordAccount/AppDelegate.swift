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

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		setStatusBarBackgroundColor(color: UIColor(hex: "CFD8DC"))
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

