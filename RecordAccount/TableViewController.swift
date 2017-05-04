//
//  TableViewController.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import RealmSwift
import MGSwipeTableCell

class TableViewController: UITableViewController, MGSwipeTableCellDelegate {

	private var itemModels: Results<ItemModel>!
	private var sections = [(date: NSDate, items: [(Int, String, Int)], extended: Bool)]()

    override func viewDidLoad() {
        super.viewDidLoad()
		do {
			let realm = try Realm()
			itemModels = realm.objects(ItemModel.self).sorted(byKeyPath: "date", ascending: false)
		} catch {
		}
		tableView.separatorInset = UIEdgeInsets.zero
		tableView.tableFooterView = UIView()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		separateItemModels()

		printSections()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "edit" {
			let editViewController = segue.destination as! EditViewController
			editViewController.parameters = sender as! [String : Any]
		}
	}

	//UITableViewDataSource
	override func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let rowInSection = sections[section].extended ? sections[section].items.count + 1 : 1
		return rowInSection
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: MGSwipeTableCell!

		if indexPath.row == 0 {
			cell = DateCustomTableViewCell(style: .default, reuseIdentifier: "dateCell")
			(cell as! DateCustomTableViewCell).setCell(date: sections[indexPath.section].date)
 		} else {
			cell = ItemCustomTableViewCell(style: .default, reuseIdentifier: "itemCell")
			let name: String = sections[indexPath.section].items[indexPath.row - 1].1
			let value: Int = sections[indexPath.section].items[indexPath.row - 1].2
			(cell as! ItemCustomTableViewCell).setCell(item: Item(name: name, value: value))
		}

		let editAction = MGSwipeButton(title: "修正", backgroundColor: UIColor(hex: "43A047")) { (tableCell) -> Bool in
			let date: NSDate = self.sections[indexPath.section].date

			let id: Int = self.sections[indexPath.section].items[indexPath.row - 1].0
			let name: String = self.sections[indexPath.section].items[indexPath.row - 1].1
			let value: Int = self.sections[indexPath.section].items[indexPath.row - 1].2

			self.performSegue(withIdentifier: "edit", sender: ["date" : date, "id" : id, "name" : name, "value" : value])
			return true
		}

		let deleteAction = MGSwipeButton(title: "削除", backgroundColor: UIColor(hex: "E53935")) { (tableCell) -> Bool in

			do {
				let realm = try Realm()
				try realm.write {
					let date = self.sections[indexPath.section].date
					if indexPath.row == 0 || self.sections[indexPath.section].items.count == 1 {
						realm.delete(realm.objects(ItemModel.self).filter("date == %@", date))
						self.sections.remove(at: indexPath.section)
						tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
					} else {
						let id = self.sections[indexPath.section].items[indexPath.row - 1].0
						realm.delete(realm.objects(ItemModel.self).filter("date == %@ AND id == %@", date, id))
						self.sections[indexPath.section].items.remove(at: indexPath.row - 1)
						tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .left)
					}
				}
			} catch {
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.tableView.reloadData()
			})
			self.printSections()
			return true
		}

		cell.delegate = self
		cell.rightButtons = (indexPath.row == 0) ? [deleteAction] : [editAction, deleteAction]
		cell.rightSwipeSettings.transition = MGSwipeTransition.static
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 0 {
			sections[indexPath.section].extended = !sections[indexPath.section].extended
			if sections[indexPath.section].extended {
				expand(tableView: tableView, indexPath: indexPath)
			} else {
				contact(tableView: tableView, indexPath: indexPath)
			}
		} else {
			let cell = tableView.cellForRow(at: indexPath) as! ItemCustomTableViewCell
			cell.showSwipe(.rightToLeft, animated: true)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}

	//アコーディオン 開
	func expand(tableView: UITableView, indexPath: IndexPath) {
		let startRow = indexPath.row + 1
		let endRow = sections[indexPath.section].items.count + 1
		var indexPaths = [IndexPath]()
		for i in startRow ..< endRow {
			indexPaths.append(IndexPath(row: i, section: indexPath.section))
		}
		tableView.insertRows(at: indexPaths, with: .fade)
		tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: indexPath.section), at: .top, animated: true)
	}

	//アコーディオン 閉
	func contact(tableView: UITableView, indexPath: IndexPath) {
		let startRow = indexPath.row + 1
		let endRow = sections[indexPath.section].items.count + 1
		var indexPaths = [IndexPath]()
		for i in startRow ..< endRow {
			indexPaths.append(IndexPath(row: i, section: indexPath.section))
		}
		tableView.deleteRows(at: indexPaths, with: .fade)
	}

	//日付でセクション分け
	func separateItemModels() {
		var extendedList: [NSDate : Bool] = [:]
		for section in sections {
			extendedList[section.date] = section.extended
		}

		sections.removeAll()
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		if itemModels.count > 0 {
			var dateSection: NSDate = itemModels[0].date
			var items = [(Int, String, Int)]()
			for item in itemModels {
				if !calendar.isDate(dateSection as Date, inSameDayAs: item.date as Date) {
					let flag: Bool = extendedList[dateSection] ?? false
					sections.append((date: dateSection, items: items, extended: flag))
					dateSection = item.date
					items.removeAll()
					items.append((item.id, item.name, item.value))
				} else {
					items.append((item.id, item.name, item.value))
				}
			}
			let flag: Bool = extendedList[dateSection] ?? false
			sections.append((date: dateSection, items: items, extended: flag))
			tableView.reloadData()
		}
	}

	func printSections() {
		for section in sections {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd"
			print(formatter.string(from: section.date as Date))
			for item in section.items {
				print("\t\(item.0) : \(item.1) : \(item.2)円")
			}
		}
		print("\n\n")
	}
}
