//
//  EditViewController.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import RealmSwift

class EditViewController: UIViewController {

	@IBOutlet weak var dateLabel: UITextField!
	@IBOutlet weak var nameLabel: UITextField!
	@IBOutlet weak var valueLabel: UITextField!
	@IBOutlet weak var backView: UIView!
	@IBOutlet weak var updateButton: UIButton!
	var datePicker: UIDatePicker!

	var parameters: [String : Any] = [:]
	var date: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

		datePicker = UIDatePicker()
		datePicker.addTarget(self, action: #selector(changedDate(_:)), for: .valueChanged)
		datePicker.datePickerMode = UIDatePickerMode.date
		dateLabel.inputView = datePicker

		backView.layer.cornerRadius = 10
		updateButton.layer.cornerRadius = 10
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBar.tintColor = UIColor.black

		let array = (parameters["date"] as! String).components(separatedBy: "-")
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		datePicker.date = calendar.date(from: DateComponents(year: Int(array[0])!, month: Int(array[1])!, day: Int(array[2])!))!
		date = parameters["date"] as! String
		
		fillBox()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
	@IBAction func tap(_ sender: Any) {
		self.view.endEditing(true)
		fillBox()
	}

	func fillBox() {
		if dateLabel.text == "" {
			let array = (parameters["date"] as! String).components(separatedBy: "-")
			dateLabel.text = String(format: "%d / %d / %d", arguments: [Int(array[0])!, Int(array[1])!, Int(array[2])!])
		}
		if nameLabel.text == "" {
			nameLabel.text = (parameters["name"] as! String)
		}
		if valueLabel.text == "" {
			valueLabel.text = String(parameters["value"] as! Int)
		}
	}

	func changedDate(_ sender: UIDatePicker) {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		date = formatter.string(from: sender.date)
		formatter.dateFormat = "yyyy / M / d"
		dateLabel.text = formatter.string(from: sender.date)
	}

	@IBAction func pushUpdate(_ sender: Any) {
		do {
			let realm = try Realm()
			let uuid: String = parameters["uuid"] as! String
			let items = realm.objects(ItemModel.self).filter("uuid == %@", uuid)
			print(items.count)
			if let item = items.first {
				print("呼ばれてる?")
				try realm.write({
					item.date = date
					item.name = nameLabel.text!
					item.value = Int(valueLabel.text!)!
				})
			}
			self.navigationController?.popViewController(animated: true)
		} catch {
			print("Save is Faild")
		}
	}

}
