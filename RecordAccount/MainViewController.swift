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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSpeechRecognizerDelegate {

	@IBOutlet weak var mainTable: UITableView!
	@IBOutlet weak var uploadButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!

	private var items = [Item]()
	private var downFlag: Bool = true
	private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? = nil
	private var recognitionTask: SFSpeechRecognitionTask? = nil
	private let audioEngine = AVAudioEngine()
	private var timer: Timer? = nil
	private var sentence: String = ""

	override func viewDidLoad() {
		super.viewDidLoad()
		speechRecognizer.delegate = self
		mainTable.delegate = self
		mainTable.dataSource = self
		mainTable.backgroundColor = UIColor.clear
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		downFlag = true
		let size: CGRect = view.bounds
		mainTable.alpha = 0.0
		mainTable.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3,
		                         width: size.width * 0.8, height: 0)
		uploadButton.alpha = 0.0
		uploadButton.isEnabled = false
		uploadButton.backgroundColor = UIColor(hex: "ECEFF1")
		uploadButton.layer.cornerRadius = 10
		uploadButton.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3 + 5,
		                            width: size.width * 0.8, height: 45)
		recordButton.isEnabled = false
		recordButton.frame = CGRect(x: size.width * 0.125, y: size.height * 0.5 - size.width * 0.375,
		                            width: size.width * 0.75, height: size.width * 0.75)

		//スキーマを変えてしまった時
//		if let fileURL = Realm.Configuration.defaultConfiguration.fileURL {
//			try! FileManager.default.removeItem(at: fileURL)
//		}

	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		let statusMic = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
		let statusSpeech = SFSpeechRecognizer.authorizationStatus()

//		if statusMic != AVAuthorizationStatus.authorized {
//			OperationQueue.main.addOperation {
//				let alert =	UIAlertController(title: "マイク使用不可",
//				           	                  message: "[設定]にてマイクの使用を許可してください。",
//				           	                  preferredStyle: .alert)
//				let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//				alert.addAction(action)
//				self.present(alert, animated: true, completion: nil)
//			}
//		}

		AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
			if granted {
				print("yass")
			} else {
				print("Permission to record not granted")
			}
		})

		if statusSpeech != SFSpeechRecognizerAuthorizationStatus.authorized {
			OperationQueue.main.addOperation {
				let alert =	UIAlertController(title: "音声認識使用不可",
				           	                  message: "[設定]にて音声認識を許可してください。",
				           	                  preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: nil)
				alert.addAction(action)
				self.present(alert, animated: true, completion: nil)
			}
		}
		recordButton.isEnabled = (statusMic == .authorized) && (statusSpeech == .authorized)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		items.removeAll()
		mainTable.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@IBAction func pushUpload(_ sender: Any) {
		saveItemData()
		moveUpAnimation()
		removeItemAnimation()
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
				inputNode.removeTap(onBus: 0)
				self.recognitionRequest = nil
				self.recognitionTask = nil
				self.appendItem()
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
		timer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false, block: { (t) in
			if self.audioEngine.isRunning {
				self.audioEngine.stop()
				self.recognitionRequest?.endAudio()
			}
		})
	}

	@IBAction func pushRecord(_ sender: Any) {
//		saveDummyItems()
		if checkNetwork() {
			if audioEngine.isRunning {
				timer?.invalidate()
				audioEngine.stop()
				recognitionRequest?.endAudio()
			} else {
				try! startRecording()
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

	func moveDownAnimation() {
		let size: CGRect = view.bounds
		UIView.animate(withDuration: 1.0, animations: {
			self.recordButton.frame = CGRect(x: size.width * 0.25, y: size.height * 0.5 + size.width * 0.125,
			                                 width: size.width * 0.5, height: size.width * 0.5)
		})
	}

	func moveUpAnimation() {
		let size: CGRect = view.bounds
		UIView.animate(withDuration: 1.0, animations: {
			self.recordButton.frame = CGRect(x: size.width * 0.125, y: size.height * 0.5 - size.width * 0.375,
			                                 width: size.width * 0.75, height: size.width * 0.75)
		})
	}

	func addItemAnimation() {
		let count: Int = items.count < 5 ? items.count : 4
		let fromPos: CGPoint = CGPoint(x: view.bounds.width * 0.1, y: view.bounds.height * 0.3)
		let toPos1: CGPoint = CGPoint(x: fromPos.x, y: fromPos.y - CGFloat(count) * 27.5)
		let toPos2: CGPoint = CGPoint(x: fromPos.x, y: fromPos.y + CGFloat(count) * 27.5 + 5)

		UIView.animate(withDuration: 1.0, animations: {
			self.mainTable.alpha = 1.0
			self.uploadButton.alpha = 1.0
			self.mainTable.frame = CGRect(x: toPos1.x, y: toPos1.y,
			                              width: self.mainTable.frame.width, height: CGFloat(count * 55))
			self.uploadButton.frame = CGRect(x: toPos2.x, y: toPos2.y,
			                                 width: self.uploadButton.frame.width, height: 45)
		}) { (finished) in
			if self.downFlag {
				self.uploadButton.isEnabled = true
				self.downFlag = false
			}
			let indexPath: IndexPath = IndexPath(row: 0, section: self.items.count - 1)
			self.mainTable.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
		}
	}

	func removeItemAnimation() {
		uploadButton.isEnabled = false
		items.removeAll()
		let size: CGRect = view.bounds
		UIView.animate(withDuration: 1.0, animations: {
			self.mainTable.alpha = 0.0
			self.mainTable.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3,
			                              width: size.width * 0.8, height: 0)
			self.uploadButton.alpha = 0.0
			self.uploadButton.frame = CGRect(x: size.width * 0.1, y: size.height * 0.3 + 5,
			                                 width: size.width * 0.8, height: 45)
		}) { (finished) in
			self.downFlag = true
			self.mainTable.reloadData()
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
		let cell = mainTable.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! MainCustomTableViewCell
		cell.setCell(item: items[indexPath.section])
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
		let date = NSDate()
		var id: Int = 0
		for item in items {
			let newItemModel = ItemModel()
			newItemModel.date = date
			newItemModel.id = id
			newItemModel.name = item.name
			newItemModel.value = item.value
			do {
				let realm = try Realm()
				try realm.write({
					realm.add(newItemModel)
				})
			} catch {
				print("Save is Faild")
			}
			id += 1
		}
	}

	//ダミー
	func saveDummyItems() {
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		let date0 = calendar.date(from: DateComponents(year: 2017, month: 4, day: 27, hour: 20, minute: 26, second: 0))!
		let date1 = calendar.date(from: DateComponents(year: 2017, month: 4, day: 28, hour: 10, minute: 30, second: 0))!
		let date2 = calendar.date(from: DateComponents(year: 2017, month: 4, day: 29, hour: 12, minute:  0, second: 10))!
		let date3 = calendar.date(from: DateComponents(year: 2017, month: 5, day:  1, hour: 13, minute: 10, second: 15))!

		var items2 = [ItemModel]()
		items2.append(makeItemModel(date: date0, id: 0, name: "うどん", value: 500))
		items2.append(makeItemModel(date: date0, id: 1, name: "そば", value: 1600))
		items2.append(makeItemModel(date: date0, id: 2, name: "きつねうどん", value: 500))
		items2.append(makeItemModel(date: date1, id: 0, name: "チョコレート", value: 400))
		items2.append(makeItemModel(date: date1, id: 1, name: "ケーキ", value: 170))
		items2.append(makeItemModel(date: date2, id: 0, name: "らーめん", value: 300))
		items2.append(makeItemModel(date: date2, id: 1, name: "カレー", value: 170))
		items2.append(makeItemModel(date: date2, id: 2, name: "カツカレー", value: 150))
		items2.append(makeItemModel(date: date2, id: 3, name: "うどん", value: 200))
		items2.append(makeItemModel(date: date3, id: 0, name: "オムライス", value: 120))
		items2.append(makeItemModel(date: date3, id: 1, name: "パン", value: 100))

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

	func makeItemModel(date: Date, id: Int, name: String, value: Int) -> ItemModel {
		let newItemModel = ItemModel()
		newItemModel.date = date as NSDate
		newItemModel.id = id
		newItemModel.name = name
		newItemModel.value = value
		return newItemModel
	}

}

