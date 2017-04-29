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
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
		separateItemModels()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	@IBAction func push(_ sender: Any) {
		self.performSegue(withIdentifier: "edit", sender: nil)
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemModels.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableCustomTableViewCell
		let item = Item(name: itemModels[indexPath.row].name, value: itemModels[indexPath.row].value)
		cell.delegate = self
		cell.setCell(item: item)

		let editAction = MGSwipeButton(title: "修正", backgroundColor: UIColor(hex: "43A047")) { (tableCell) -> Bool in
			self.performSegue(withIdentifier: "edit", sender: nil)
			return true
		}

		let deleteAction = MGSwipeButton(title: "削除", backgroundColor: UIColor(hex: "E53935")) { (tableCell) -> Bool in
			do {
				let realm = try Realm()
				try realm.write {
					realm.delete(self.itemModels[indexPath.row])
				}
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
			}
			tableView.reloadData()
			return true
		}

		cell.rightButtons = [editAction, deleteAction]
		cell.rightSwipeSettings.transition = MGSwipeTransition.static
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! TableCustomTableViewCell
		cell.showSwipe(.rightToLeft, animated: true)
		tableView.deselectRow(at: indexPath, animated: true)
	}

	//日付をセクションとして分けるとこまでできた
	func separateItemModels() {
		var dateSection: NSDate = itemModels[0].date
		var items = [(Int, String, Int)]()
		for item in itemModels {
			if dateSection.compare(item.date as Date) != .orderedSame {
				sections.append((date: dateSection, items: items, extended: false))
				dateSection = item.date
				items.removeAll()
				items.append((item.id, item.name, item.value))
			} else {
				items.append((item.id, item.name, item.value))
			}
		}
		sections.append((date: dateSection, items: items, extended: false))
	}

}
