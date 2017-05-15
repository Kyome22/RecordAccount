//
//  HintViewController.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/05/15.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

class HintViewController: UIPageViewController {

	private var FirstView: UIViewController!
	private var SecondView: UIViewController!
	private var ThirdView: UIViewController!
	var pageControl: UIPageControl!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor(hex: "00897B")

		FirstView = storyboard?.instantiateViewController(withIdentifier: "FirstHint")
		SecondView = storyboard?.instantiateViewController(withIdentifier: "SecondHint")
		ThirdView = storyboard?.instantiateViewController(withIdentifier: "ThirdHint")
		self.dataSource = self
	}

	override func viewWillAppear(_ animated: Bool) {
		setViewControllers([FirstView],
		                   direction: .forward, animated: true, completion: nil)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		pageControl = self.view.subviews.filter{ $0 is UIPageControl }.first! as! UIPageControl
		pageControl.backgroundColor = UIColor.clear
		pageControl.pageIndicatorTintColor = UIColor(hex: "E0E0E0")
		pageControl.currentPageIndicatorTintColor = UIColor(hex: "FDD835")
		pageControl.center = self.view.center
		pageControl.frame = CGRect(x: pageControl.frame.origin.x,
		                           y: self.view.frame.height - 90,
		                           width: pageControl.frame.width,
		                           height: pageControl.frame.height)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()

	}

	func getView(page: Int) -> UIViewController {
		if page == 1 {
			return FirstView
		} else if page == 2 {
			return SecondView
		} else {
			return ThirdView
		}
	}

}

extension HintViewController: UIPageViewControllerDataSource {

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		print(viewController.restorationIdentifier!)
		if viewController.restorationIdentifier == "ThirdHint" {
			return getView(page: 2)
		} else if viewController.restorationIdentifier == "SecondHint" {
			return getView(page: 1)
		} else {
			return nil
		}
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		print(viewController.restorationIdentifier!)
		if viewController.restorationIdentifier == "FirstHint" {
			return getView(page: 2)
		} else if viewController.restorationIdentifier == "SecondHint" {
			return getView(page: 3)
		} else {
			return nil
		}
	}

	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return 3
	}

	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 0
	}

}
