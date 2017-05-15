//
//  MainCustomTableViewCell.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

class MainCustomTableViewCell: UITableViewCell {

	public var itemNameField = UITextField()
	public var itemValueField = UITextField()
	private var unitLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	func setCell(item: Item) {
		self.layer.cornerRadius = 10
		self.layer.backgroundColor = UIColor(hex: "ECEFF1").cgColor
		let size: CGRect = self.bounds
		itemNameField.frame = CGRect(x: size.width * 0.05, y: size.height * 0.05,
		                             width: size.width * 0.5, height: size.height * 0.9)
		itemNameField.font = UIFont(name: itemValueField.font!.fontName, size: 21)
		itemNameField.text = item.name
		itemNameField.keyboardType = UIKeyboardType.default

		itemValueField.frame = CGRect(x: size.width * 0.6, y: size.height * 0.05,
		                              width: size.width * 0.275, height: size.height * 0.9)
		itemValueField.textAlignment = .right
		itemValueField.font = UIFont(name: itemValueField.font!.fontName, size: 21)
		itemValueField.text = String(item.value)
		itemValueField.keyboardType = UIKeyboardType.numberPad

		unitLabel.frame = CGRect(x: size.width * 0.875, y: size.height * 0.05,
		                         width: size.width * 0.075, height: size.height * 0.9)
		unitLabel.font = UIFont(name: itemValueField.font!.fontName, size: 21)
		unitLabel.text = "円"

		self.contentView.addSubview(itemNameField)
		self.contentView.addSubview(itemValueField)
		self.contentView.addSubview(unitLabel)
	}

}
