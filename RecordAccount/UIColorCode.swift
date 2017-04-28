//
//  UIColorCode.swift
//  Slantock
//
//  Created by Takuto Nakamura on 2017/01/26.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

extension UIColor {
	convenience init(hex: String, alpha: CGFloat) {
		let r = hex.startIndex;
		let g = hex.index(r, offsetBy: 2);
		let b = hex.index(g, offsetBy: 2);
		let e = hex.index(b, offsetBy: 2);

		let hexR:String = hex.substring(with: r ..< g);
		let hexG:String = hex.substring(with: g ..< b);
		let hexB:String = hex.substring(with: b ..< e);

		let R255:CGFloat = CGFloat(Int(hexR, radix: 16) ?? 0)/255;
		let G255:CGFloat = CGFloat(Int(hexG, radix: 16) ?? 0)/255;
		let B255:CGFloat = CGFloat(Int(hexB, radix: 16) ?? 0)/255;

		self.init(red: R255, green: G255, blue: B255, alpha: alpha);
	}

	convenience init(hex: String) {
		self.init(hex: hex, alpha: 1.0);
	}
}
