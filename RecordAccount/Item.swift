//
//  Item.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import Foundation

class Item: NSObject {
	var name: String
	var value: Int

	init(name: String, value: Int) {
		self.name = name
		self.value = value
	}
}
