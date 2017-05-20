//
//  EditViewController.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import RealmSwift

class EditViewController: UIViewController, UITextFieldDelegate {

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
		dateLabel.delegate = self
		nameLabel.delegate = self
		valueLabel.delegate = self

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

		let numberToolbar = UIToolbar()
		numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
		                       UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(tap(_:)))]
		numberToolbar.sizeToFit()
		numberToolbar.tintColor = UIColor(hex: "00897B")
		valueLabel.inputAccessoryView = numberToolbar
		dateLabel.inputAccessoryView = numberToolbar

		fillBox()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	func textFieldDidBeginEditing(_ textField: UITextField) {
		updateButton.isEnabled = false
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		fillBox()
		updateButton.isEnabled = true
		return true
	}
    
	@IBAction func tap(_ sender: Any) {
		self.view.endEditing(true)
		fillBox()
		updateButton.isEnabled = true
	}

	func fillBox() {
		if dateLabel.text == "" {
			let array = (parameters["date"] as! String).components(separatedBy: "-")
			dateLabel.text = String(format: "%d / %d / %d%@",
			                        arguments: [Int(array[0])!, Int(array[1])!, Int(array[2])!, convertWeekday(array[3])])
		}
		if nameLabel.text == "" {
			nameLabel.text = (parameters["name"] as! String)
		}
		if valueLabel.text == "" {
			valueLabel.text = String(parameters["value"] as! Int)
		}
	}

	func convertWeekday(_ day: String) -> String {
		switch day {
		case "1": return "  日曜日"
		case "2": return "  月曜日"
		case "3": return "  火曜日"
		case "4": return "  水曜日"
		case "5": return "  木曜日"
		case "6": return "  金曜日"
		case "7": return "  土曜日"
		default:
			return ""
		}
	}

	func changedDate(_ sender: UIDatePicker) {
		let weekday = Calendar.current.component(Calendar.Component.weekday, from: sender.date)
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		date = formatter.string(from: sender.date) + "-" + String(weekday)
		formatter.dateFormat = "yyyy / M / d"
		dateLabel.text = formatter.string(from: sender.date) + convertWeekday(String(weekday))
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
