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
	var newDate: Date? = nil

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
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy / M / d"
			dateLabel.text = formatter.string(from: parameters["date"] as! Date)
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
		formatter.dateFormat = "yyyy / M / d"
		newDate = sender.date
		dateLabel.text = formatter.string(from: newDate!)
	}

	@IBAction func pushUpdate(_ sender: Any) {
		do {
			let realm = try Realm()
			let date: NSDate = parameters["date"] as! NSDate
			let id: Int = parameters["id"] as! Int
			let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
			if (newDate != nil) && !(calendar.isDate(date as Date, inSameDayAs: newDate!)) {
				let allItems = realm.objects(ItemModel.self)
				for item in allItems {
					if calendar.isDate(newDate!, inSameDayAs: item.date as Date) {
						newDate = item.date as Date
						break
					}
				}
				var newId: Int = 0
				let newDateItems = allItems.filter("date == %@", newDate! as NSDate).sorted(byKeyPath: "id", ascending: false)
				if let last = newDateItems.first {
					newId = last.id + 1
				}
				let items = realm.objects(ItemModel.self).filter("date == %@ AND id == %@", date, id)
				if let item = items.first {
					try realm.write({
						item.date = newDate! as NSDate
						item.id = newId
						item.name = nameLabel.text!
						item.value = Int(valueLabel.text!)!
					})
				}
			} else {
				let items = realm.objects(ItemModel.self).filter("date == %@ AND id == %@", date, id)
				if let item = items.first {
					try realm.write({ 
						item.name = nameLabel.text!
						item.value = Int(valueLabel.text!)!
					})
				}
			}
			self.navigationController?.popViewController(animated: true)
		} catch {
			print("Save is Faild")
		}
	}

}
