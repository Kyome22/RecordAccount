//
//  MainController.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/22.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import Speech
import RealmSwift
import SystemConfiguration

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSpeechRecognizerDelegate, MainCustomTableViewCellDelegate {

	@IBOutlet weak var mainTable: UITableView!
	@IBOutlet weak var uploadButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var attentionImage: UIImageView!
	private var circle = CircleView()

	private var first: Bool = true
	private var items = [Item]()
	private var downFlag: Bool = true
	private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? = nil
	private var recognitionTask: SFSpeechRecognitionTask? = nil
	private let audioEngine = AVAudioEngine()
	private var timer: Timer? = nil
	private var sentence: String = ""
	private var itemRow: Int = 0
	private var accessMainTable: Bool = false

	private let DEBUG: Int = 0 //release: 0, changed schema: 1, add dummy items: 2, save dummy items: 3

	override func viewDidLoad() {
		super.viewDidLoad()
		speechRecognizer.delegate = self
		mainTable.delegate = self
		mainTable.dataSource = self
		mainTable.backgroundColor = UIColor.clear
		view.addSubview(circle)
		view.sendSubview(toBack: circle)
		first = true
		downFlag = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if first {
			let size: CGRect = view.bounds
			checkViewSize()
			mainTable.alpha = 0.0
			mainTable.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3,
			                         width: size.width * 0.8, height: 0)
			mainTable.separatorColor = UIColor.clear

			uploadButton.alpha = 0.0
			uploadButton.isEnabled = false
			mainTable.isUserInteractionEnabled = false
			uploadButton.backgroundColor = UIColor(hex: "ECEFF1")
			uploadButton.layer.cornerRadius = 10
			uploadButton.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3 + 5,
			                            width: size.width * 0.8, height: 45)
			recordButton.isEnabled = false
			recordButton.frame = CGRect(x: size.width * 0.125, y: size.height * 0.5 - size.width * 0.375,
			                            width: size.width * 0.75, height: size.width * 0.75)
			circle.frame = CGRect(x: size.width * 0.125, y: size.height * 0.5 - size.width * 0.375,
			                      width: size.width * 0.75, height: size.width * 0.75)

			attentionImage.frame = CGRect(x: size.width * 0.2, y: size.height * 0.5 + size.width * 0.36,
			                              width: size.width * 0.6, height: size.width * 0.221)
			attentionImage.alpha = 0.0


			if DEBUG == 1 {
				if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
					try! FileManager.default.removeItem(at: fileURL)
				}
			}
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if first {
			var audioFlag: Bool = false
			var speechFlag: Bool = false

			let semaphore = DispatchSemaphore(value: 0)

			AVAudioSession.sharedInstance().requestRecordPermission( { (granted: Bool) -> Void in
				if granted {
					audioFlag = true
				} else {
					let alert =	UIAlertController(title: "マイク使用不可",
					           	                  message: "[設定]にてマイクの使用を許可してください。",
					           	                  preferredStyle: .alert)
					let action = UIAlertAction(title: "OK", style: .default, handler: nil)
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
				semaphore.signal()
			})

			SFSpeechRecognizer.requestAuthorization { (status) in
				if status == .authorized {
					speechFlag = true
				} else {
					let alert =	UIAlertController(title: "音声認識使用不可",
					           	                  message: "[設定]にて音声認識を許可してください。",
					           	                  preferredStyle: .alert)
					let action = UIAlertAction(title: "OK", style: .default, handler: nil)
					alert.addAction(action)
					self.present(alert, animated: true, completion: nil)
				}
				semaphore.signal()
			}

			semaphore.wait()
			semaphore.wait()
			recordButton.isEnabled = audioFlag && speechFlag
			if audioFlag && speechFlag {
				fadeAnimation(io: true)
			}
			first = false
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	func willstartEditing() {
		self.uploadButton.isEnabled = false
		self.mainTable.isUserInteractionEnabled = false
	}

	func didEndEditing(section: Int, name: String, value: Int) {
		items[section].name = name
		items[section].value = value
		self.uploadButton.isEnabled = true
		self.mainTable.isUserInteractionEnabled = true
	}

	func removeCell(section: Int) {
		removeItemAnimation(all: false, section: section)
	}

	@IBAction func pushUpload(_ sender: Any) {
		saveItemData()
		removeItemAnimation(all: true)
	}

	func startRecording() throws {
		if let recognitionTask = recognitionTask {
			recognitionTask.cancel()
			self.recognitionTask = nil
		}

		let audioSession = AVAudioSession.sharedInstance()
		try audioSession.setCategory(AVAudioSessionCategoryRecord)
		try audioSession.setMode(AVAudioSessionModeMeasurement)
		try audioSession.setActive(true, with: .notifyOthersOnDeactivation)

		recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
		guard let inputNode = audioEngine.inputNode else {
			fatalError("Audio engine has no input node")
		}
		guard let recognitionRequest = recognitionRequest else {
			fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object")
		}
		recognitionRequest.shouldReportPartialResults = true

		recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { (result, error) in
			var isFinal = false

			if let result = result {
				self.sentence = result.bestTranscription.formattedString
				isFinal = result.isFinal
			}

			if error != nil || isFinal {
				self.audioEngine.stop()
				self.circle.stop()
				inputNode.removeTap(onBus: 0)
				self.recognitionRequest = nil
				self.recognitionTask = nil
				self.appendItem()
				self.uploadButton.isEnabled = true
				self.mainTable.isUserInteractionEnabled = true
				self.recordButton.setImage(UIImage(named: "reco.png"), for: .normal)
			}
		}

		let recordingFormat = inputNode.outputFormat(forBus: 0)
		inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
			self.recognitionRequest?.append(buffer)
		}

		audioEngine.prepare()
		try audioEngine.start()
		recordButton.setImage(UIImage(named: "stop.png"), for: .normal)
		circle.start()
		timer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false, block: { (t) in
			if self.audioEngine.isRunning {
				self.audioEngine.stop()
				self.circle.stop()
				self.recognitionRequest?.endAudio()
			}
		})
	}

	@IBAction func pushRecord(_ sender: Any) {
		if DEBUG == 2 {
			addDummyItems()
		} else if DEBUG == 3 {
			saveDummyItems()
		} else {
			if checkNetwork() {
				if audioEngine.isRunning {
					timer?.invalidate()
					audioEngine.stop()
					circle.stop()
					recognitionRequest?.endAudio()
				} else {
					try! startRecording()
					uploadButton.isEnabled = false
					mainTable.isUserInteractionEnabled = false
					fadeAnimation(io: false)
				}
			} else {
				let alert =	UIAlertController(title: "ネットワークエラー",
				           	                  message: "インターネットに接続してください。",
				           	                  preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: nil)
				alert.addAction(action)
				self.present(alert, animated: true, completion: nil)
			}
		}
	}

	func fadeAnimation(io: Bool) {
		UIView.animate(withDuration: 0.4, animations: {
			self.attentionImage.alpha = io ? 1.0 : 0.0
		})
	}

	func moveDownAnimation() {
		let size: CGRect = view.bounds
		UIView.animate(withDuration: 0.7, animations: {
			self.recordButton.frame = CGRect(x: size.width * 0.25, y: size.height * 0.54 + size.width * 0.125,
			                                 width: size.width * 0.5, height: size.width * 0.5)
			self.circle.frame = CGRect(x: size.width * 0.25, y: size.height * 0.54 + size.width * 0.125,
			                                 width: size.width * 0.5, height: size.width * 0.5)
		})
	}

	func moveUpAnimation() {
		let size: CGRect = view.bounds
		UIView.animate(withDuration: 0.7, animations: { 
			self.recordButton.frame = CGRect(x: size.width * 0.125, y: size.height * 0.5 - size.width * 0.375,
			                                 width: size.width * 0.75, height: size.width * 0.75)
			self.circle.frame = CGRect(x: size.width * 0.125, y: size.height * 0.5 - size.width * 0.375,
			                           width: size.width * 0.75, height: size.width * 0.75)
		}) { (finished) in
			self.fadeAnimation(io: true)
		}
	}

	func addItemAnimation() {
		let count: Int = items.count <= itemRow ? items.count : itemRow
		let fromPos: CGPoint = CGPoint(x: view.bounds.width * 0.1, y: view.bounds.height * 0.3)
		let toPos1: CGPoint = CGPoint(x: fromPos.x, y: fromPos.y - CGFloat(count) * 27.5)
		let toPos2: CGPoint = CGPoint(x: fromPos.x, y: fromPos.y + CGFloat(count) * 27.5 + 5)

		UIView.animate(withDuration: 0.7, animations: {
			self.mainTable.alpha = 1.0
			self.uploadButton.alpha = 1.0
			self.mainTable.frame = CGRect(x: toPos1.x, y: toPos1.y,
			                              width: self.mainTable.frame.width, height: CGFloat(count * 55))
			self.uploadButton.frame = CGRect(x: toPos2.x, y: toPos2.y,
			                                 width: self.uploadButton.frame.width, height: 45)
		}) { (finished) in
			if self.downFlag {
				self.uploadButton.isEnabled = true
				self.mainTable.isUserInteractionEnabled = true
				self.downFlag = false
			}
			let indexPath: IndexPath = IndexPath(row: 0, section: self.items.count - 1)
			self.mainTable.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
		}
	}

	func removeItemAnimation(all: Bool, section: Int = 0) {
		if all || items.count - 1 == 0 {
			uploadButton.isEnabled = false
			items.removeAll()
			let size: CGRect = view.bounds
			UIView.animate(withDuration: 0.3, animations: {
				self.mainTable.alpha = 0.0
				self.mainTable.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3,
				                              width: size.width * 0.8, height: 0)
				self.uploadButton.alpha = 0.0
				self.uploadButton.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3 + 5,
				                                 width: size.width * 0.8, height: 45)
			}) { (finished) in
				self.downFlag = true
				self.mainTable.reloadData()
				self.moveUpAnimation()
			}
		} else {
			self.items.remove(at: section)
			self.mainTable.deleteSections(IndexSet(integer: section), with: .left)
			UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
				let count: Int = self.items.count <= self.itemRow ? self.items.count : self.itemRow
				let fromPos: CGPoint = CGPoint(x: self.view.bounds.width * 0.1, y: self.view.bounds.height * 0.3)
				let toPos1: CGPoint = CGPoint(x: fromPos.x, y: fromPos.y - CGFloat(count) * 27.5)
				let toPos2: CGPoint = CGPoint(x: fromPos.x, y: fromPos.y + CGFloat(count) * 27.5 + 5)
				self.mainTable.frame = CGRect(x: toPos1.x, y: toPos1.y,
				                              width: self.mainTable.frame.width, height: CGFloat(count * 55))
				self.uploadButton.frame = CGRect(x: toPos2.x, y: toPos2.y,
				                                 width: self.uploadButton.frame.width, height: 45)
			}, completion: { (finished) in
				let indexPath: IndexPath = IndexPath(row: 0, section: self.items.count - 1)
				self.mainTable.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
			})
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
				self.mainTable.reloadData()
			})
		}
	}

	func parser() -> [(String, Int)] {
		var results = [(String, Int)]()
		let pattern: String = "[1-9][0-9,]*円"
		var str: String = sentence
		while true {
			let range: Range<String.Index>? = str.range(of: pattern,
			                                            options: .regularExpression,
			                                            range: str.startIndex ..< str.endIndex,
			                                            locale: .current)
			if range != nil {
				if str.startIndex < range!.lowerBound {
					var valueStr: String = str[range!]
					valueStr = valueStr.replacingOccurrences(of: ",", with: "")
					valueStr = valueStr.replacingOccurrences(of: "円", with: "")
					let value: Int = Int(valueStr)!
					results.append((str[str.startIndex ..< range!.lowerBound], value))
				}
				if range!.upperBound != str.endIndex {
					str = str[range!.upperBound ..< str.endIndex]
				} else {
					break
				}
			} else {
				break
			}
		}
		sentence = ""
		return results
	}

	func appendItem() {
		let results: [(name: String, value: Int)] = parser()
		for result in results {
			items.append(Item(name: result.name, value: result.value))
		}
		mainTable.reloadData()

		if results.count > 0 {
			if downFlag {
				moveDownAnimation()
			}
			addItemAnimation()
		} else {
			if downFlag {
				self.fadeAnimation(io: true)
			}
		}
	}

	//UITableViewDelegate
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 5
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 5
	}

	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = UIColor.clear
	}

	func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		view.tintColor = UIColor.clear
	}

	//UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell =	MainCustomTableViewCell()
		cell.setCell(section: indexPath.section, item: items[indexPath.section], width: mainTable.frame.width)
		cell.delegate = self
		return cell
	}

	//NetWorkCheck
	func checkNetwork() -> Bool {
		let reach = SCNetworkReachabilityCreateWithName(nil, "google.com")!
		var flags = SCNetworkReachabilityFlags.connectionAutomatic
		if !SCNetworkReachabilityGetFlags(reach, &flags) {
			return false
		}
		let isReachable = flags.rawValue & UInt32(kSCNetworkFlagsReachable) != 0
		let needsConnection = flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired) != 0
		return isReachable && !needsConnection
	}

	func saveItemData() {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		var date: String = formatter.string(from: Date())
		let weekday = Calendar.current.component(Calendar.Component.weekday, from: Date())
		date += "-" + String(weekday)
		do {
			let realm = try Realm()
			for item in items {
				let newItemModel = ItemModel()
				newItemModel.date = date
				newItemModel.uuid = UUID().uuidString
				newItemModel.name = item.name
				newItemModel.value = item.value
				try realm.write({
					realm.add(newItemModel)
				})
			}
		} catch {
			print("Save is Faild")
		}
	}

	//ダミー
	func addDummyItems() {
		items.append(Item(name: "うどん", value: 300))
		items.append(Item(name: "飲み物", value: 140))
		items.append(Item(name: "駐輪場代", value: 150))

		mainTable.reloadData()
		if downFlag {
			moveDownAnimation()
		}
		addItemAnimation()
	}

	func saveDummyItems() {
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		let date0 = calendar.date(from: DateComponents(year: 2017, month: 4, day: 27))!
		let date1 = calendar.date(from: DateComponents(year: 2017, month: 4, day: 28))!
		let date2 = calendar.date(from: DateComponents(year: 2017, month: 4, day: 29))!
		let date3 = calendar.date(from: DateComponents(year: 2017, month: 5, day:  1))!

		var items2 = [ItemModel]()
		items2.append(makeItemModel(date: date0, name: "うどん", value: 500))
		items2.append(makeItemModel(date: date0, name: "そば", value: 1600))
		items2.append(makeItemModel(date: date0, name: "きつねうどん", value: 500))
		items2.append(makeItemModel(date: date1, name: "チョコレート", value: 400))
		items2.append(makeItemModel(date: date1, name: "ケーキ", value: 170))
		items2.append(makeItemModel(date: date2, name: "らーめん", value: 300))
		items2.append(makeItemModel(date: date2, name: "カレー", value: 170))
		items2.append(makeItemModel(date: date2, name: "カツカレー", value: 150))
		items2.append(makeItemModel(date: date2, name: "うどん", value: 200))
		items2.append(makeItemModel(date: date3, name: "オムライス", value: 120))
		items2.append(makeItemModel(date: date3, name: "パン", value: 100))

		for item in items2 {
			do {
				let realm = try Realm()
				try realm.write({
					realm.add(item)
				})
			} catch {
				print("Save is Faild")
			}
		}

	}

	func makeItemModel(date: Date, name: String, value: Int) -> ItemModel {
		let weekday = Calendar.current.component(Calendar.Component.weekday, from: date)
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		let dateStr: String = formatter.string(from: date) + "-" + String(weekday)

		let newItemModel = ItemModel()
		newItemModel.date = dateStr
		newItemModel.uuid = UUID().uuidString
		newItemModel.name = name
		newItemModel.value = value
		
		return newItemModel
	}

	func checkViewSize() {
		let modelSize = self.view.frame.size
		switch modelSize {
		case CGSize(width: 320, height: 568):
			itemRow = 4
		case CGSize(width: 375, height: 667):
			itemRow = 5
		case CGSize(width: 414, height: 736):
			itemRow = 6
		default:
			itemRow = 5
		}
	}
}

