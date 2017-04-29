//
//  RecordAccountRealmObject.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import RealmSwift

class ItemModel: Object {
	dynamic var date: NSDate = NSDate()
	dynamic var id: Int = 0
	dynamic var name: String = ""
	dynamic var value: Int = 0
}
