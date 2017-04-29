//
//  TableViewController.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/29.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {

	private var itemModels: Results<ItemModel>!

    override func viewDidLoad() {
        super.viewDidLoad()
		do {
			let realm = try Realm()
			itemModels = realm.objects(ItemModel.self)
		} catch {
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
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
		cell.setCell(item: item)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let editAction = UITableViewRowAction(style: .normal, title: "修正") { (action, indexPath) in
			self.performSegue(withIdentifier: "edit", sender: nil)
		}
		editAction.backgroundColor = UIColor(hex: "43A047") //green


		let deleteAction = UITableViewRowAction(style: .default, title: "削除") { (action, indexPath) in
			do {
				let realm = try Realm()
				try realm.write {
					realm.delete(self.itemModels[indexPath.row])
				}
				tableView.deleteRows(at: [indexPath], with: .fade)
			} catch {
			}
			tableView.reloadData()
		}
		deleteAction.backgroundColor = UIColor(hex: "E53935") //red
		return [editAction, deleteAction]
	}

}
