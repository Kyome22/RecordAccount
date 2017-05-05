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
	private var sections = [(date: String, items: [(uuid: String, name: String, value: Int)], extended: Bool)]()

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
			let date: String = self.sections[indexPath.section].date
			let uuid: String = self.sections[indexPath.section].items[indexPath.row - 1].uuid
			let name: String = self.sections[indexPath.section].items[indexPath.row - 1].name
			let value: Int = self.sections[indexPath.section].items[indexPath.row - 1].value

			self.performSegue(withIdentifier: "edit", sender: ["date" : date, "uuid" : uuid, "name" : name, "value" : value])
			return true
		}

		let deleteAction = MGSwipeButton(title: "削除", backgroundColor: UIColor(hex: "E53935")) { (tableCell) -> Bool in
			do {
				let realm = try Realm()
				try realm.write {
					let date: String = self.sections[indexPath.section].date
					if indexPath.row == 0 || self.sections[indexPath.section].items.count == 1 {
						realm.delete(realm.objects(ItemModel.self).filter("date == %@", date))
						self.sections.remove(at: indexPath.section)
						tableView.deleteSections(IndexSet(integer: indexPath.section), with: .left)
					} else {
						let uuid = self.sections[indexPath.section].items[indexPath.row - 1].uuid
						realm.delete(realm.objects(ItemModel.self).filter("uuid == %@", uuid))
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
		var extendedList: [String : Bool] = [:]
		for section in sections {
			extendedList[section.date] = section.extended
		}

		sections.removeAll()
		if itemModels.count > 0 {
			var dateSection: String = itemModels[0].date
			var items = [(uuid: String, name: String, value: Int)]()
			for item in itemModels {
				if dateSection != item.date {
					let flag: Bool = extendedList[dateSection] ?? false
					sections.append((date: dateSection, items: items, extended: flag))
					dateSection = item.date
					items.removeAll()
					items.append((item.uuid, item.name, item.value))
				} else {
					items.append((item.uuid, item.name, item.value))
				}
			}
			let flag: Bool = extendedList[dateSection] ?? false
			sections.append((date: dateSection, items: items, extended: flag))
			tableView.reloadData()
		}
	}

	func printSections() {
		for section in sections {
			print(section.date)
			for item in section.items {
				print("\t\(item.uuid) : \(item.name) : \(item.value)円")
			}
		}
		print("\n\n")
	}
}
