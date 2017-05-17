//
//  MainCustomTableViewCell.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

class MainCustomTableViewCell: UITableViewCell, UITextFieldDelegate {

	public var itemNameField = UITextField()
	public var itemValueField = UITextField()
	private var unitLabel = UILabel()
	private var name_: String!
	private var value_: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	func setCell(item: Item) {
		self.name_ = item.name
		self.value_ = item.value
		self.layer.cornerRadius = 10
		self.layer.backgroundColor = UIColor(hex: "ECEFF1").cgColor
		let size: CGRect = self.bounds
		itemNameField.delegate = self
		itemNameField.frame = CGRect(x: size.width * 0.05, y: size.height * 0.05,
		                             width: size.width * 0.5, height: size.height * 0.9)
		itemNameField.font = UIFont(name: itemValueField.font!.fontName, size: 21)
		itemNameField.text = item.name
		itemNameField.placeholder = item.name
		itemNameField.keyboardType = UIKeyboardType.default
		itemNameField.returnKeyType = UIReturnKeyType.done

		itemValueField.delegate = self
		itemValueField.frame = CGRect(x: size.width * 0.6, y: size.height * 0.05,
		                              width: size.width * 0.275, height: size.height * 0.9)
		itemValueField.textAlignment = .right
		itemValueField.font = UIFont(name: itemValueField.font!.fontName, size: 21)
		itemValueField.text = String(item.value)
		itemValueField.placeholder = String(item.value)
		itemValueField.keyboardType = UIKeyboardType.numberPad
		let numberToolbar = UIToolbar()
		numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
		                       UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(endEdit))]
		numberToolbar.sizeToFit()
		numberToolbar.tintColor = UIColor(hex: "00897B")
		itemValueField.inputAccessoryView = numberToolbar

		unitLabel.frame = CGRect(x: size.width * 0.875, y: size.height * 0.05,
		                         width: size.width * 0.075, height: size.height * 0.9)
		unitLabel.font = UIFont(name: itemValueField.font!.fontName, size: 21)
		unitLabel.text = "円"

		self.contentView.addSubview(itemNameField)
		self.contentView.addSubview(itemValueField)
		self.contentView.addSubview(unitLabel)
	}

	func endEdit() {
		self.endEditing(true)
		if itemNameField.text == "" {
			itemNameField.text = self.name_
		}
		if itemValueField.text == "" {
			itemValueField.text = String(self.value_)
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		endEdit()
		return true
	}

}
