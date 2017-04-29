//
//  MainCustomTableViewCell.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit

class MainCustomTableViewCell: UITableViewCell {

	private var itemNameLabel = UILabel()
	private var itemValueLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	func setCell(item: Item) {
		self.layer.cornerRadius = 10
		self.layer.backgroundColor = UIColor(hex: "ECEFF1").cgColor
		let size: CGRect = self.bounds
		itemNameLabel.frame = CGRect(x: size.width * 0.05, y: size.height * 0.05,
		                             width: size.width * 0.5, height: size.height * 0.9)
		itemNameLabel.font = UIFont(name: itemValueLabel.font.fontName, size: 21)
		itemNameLabel.text = item.name

		itemValueLabel.frame = CGRect(x: size.width * 0.6, y: size.height * 0.05,
		                              width: size.width * 0.35, height: size.height * 0.9)
		itemValueLabel.textAlignment = .right
		itemValueLabel.font = UIFont(name: itemValueLabel.font.fontName, size: 21)
		itemValueLabel.text = String(item.value) + "円"
		self.addSubview(itemNameLabel)
		self.addSubview(itemValueLabel)
	}

}
