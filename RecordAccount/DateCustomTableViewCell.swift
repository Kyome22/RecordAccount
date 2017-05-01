//
//  DateCustomTableViewCell.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class DateCustomTableViewCell: MGSwipeTableCell {

	private var dateLabel = UILabel()
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	func setCell(date: NSDate) {
		let size: CGRect = self.bounds
		self.layer.backgroundColor = UIColor.white.cgColor
		dateLabel.frame = CGRect(x: size.width * 0.05, y: size.height * 0.05,
		                             width: size.width * 0.5, height: size.height * 0.9)
		dateLabel.font = UIFont(name: dateLabel.font.fontName, size: 21)
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy/MM/dd"
		dateLabel.text = formatter.string(from: date as Date)
		self.contentView.addSubview(dateLabel)
	}

}
