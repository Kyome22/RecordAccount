//
//  CircleView.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/05/13.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

class CircleView: UIView {
	private var endAngle: CGFloat = -CGFloat(Double.pi * 0.5)
	private var timer: Timer?
	private var count: Int = 0
	private var radiusRatio: CGFloat = 1.0

	init() {
		super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		self.backgroundColor = UIColor.clear
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.backgroundColor = UIColor.clear
	}

    override func draw(_ rect: CGRect) {
		drawCircle()
    }

	func drawCircle() {
		let outerRadius: CGFloat = self.frame.width * 0.47 * radiusRatio
		let innerRadius: CGFloat = self.frame.width * 0.43 * radiusRatio
		let path = UIBezierPath();
		path.move(to: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2))
		path.addArc(withCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2),
		            radius: outerRadius, startAngle: -CGFloat(Double.pi * 0.5), endAngle: endAngle, clockwise: true)
		path.addArc(withCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2),
		            radius: innerRadius, startAngle: endAngle, endAngle: -CGFloat(Double.pi * 0.5), clockwise: false)
		path.close()
		UIColor(hex: "FFFFFF", alpha: 1.0).setFill()
		path.fill()
	}

	func start() {
		timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (t) in
			self.endAngle += CGFloat(Double.pi * 0.0125)
			self.setNeedsDisplay()
		})
	}

	func stop() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (t) in
			self.radiusRatio -= 0.02
			self.count += 1
			if self.count > 10 {
				self.timer?.invalidate()
				self.endAngle = -CGFloat(Double.pi * 0.5)
				self.count = 0
				self.radiusRatio = 1.0
			}
			self.setNeedsDisplay()
		})
		timer?.fire()
	}

}
