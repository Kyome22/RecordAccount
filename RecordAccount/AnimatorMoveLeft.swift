//
//  AnimatorMoveLeft.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/28.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

class AnimatorMoveLeft: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.5
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let from: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
		let to:UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
		let container: UIView = transitionContext.containerView
		container.insertSubview(to.view, aboveSubview: from.view)
		to.view.alpha = 0.0

		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { 
			from.view.alpha = 0.0
			to.view.alpha = 1.0
		}) { (value) in
			transitionContext.completeTransition(true)
		}
	}
}
