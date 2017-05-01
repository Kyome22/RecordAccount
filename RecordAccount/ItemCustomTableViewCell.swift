//
//  ItemCustomTableViewCell.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/05/01.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ItemCustomTableViewCell: MGSwipeTableCell {

	private var itemNameLabel = UILabel()
	private var itemValueLabel = UILabel()

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	func setCell(item: Item) {
		let size: CGRect = self.bounds
		self.layer.backgroundColor = UIColor.white.cgColor
		itemNameLabel.frame = CGRect(x: size.width * 0.1, y: size.height * 0.05,
		                             width: size.width * 0.45, height: size.height * 0.9)
		itemNameLabel.font = UIFont(name: itemValueLabel.font.fontName, size: 21)
		itemNameLabel.text = item.name

		itemValueLabel.frame = CGRect(x: size.width * 0.6, y: size.height * 0.05,
		                              width: size.width * 0.35, height: size.height * 0.9)
		itemValueLabel.textAlignment = .right
		itemValueLabel.text = String(item.value) + "円"
		self.contentView.addSubview(itemNameLabel)
		self.contentView.addSubview(itemValueLabel)
	}

}
