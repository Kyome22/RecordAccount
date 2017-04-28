//
//  mainController.swift
//  RecordAccount
//
//  Created by Takuto Nakamura on 2017/04/22.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import UIKit
import Speech
import SystemConfiguration

class mainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSpeechRecognizerDelegate {

	@IBOutlet weak var mainTable: UITableView!
	@IBOutlet weak var uploadButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!

	private var items = [Item]()
	private var firstTime: Bool = true
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
		firstTime = true
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
		recordButton.bounds = CGRect(x: 0, y: 0, width: size.width * 0.75, height: size.width * 0.75)
		recordButton.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
	}

	override func viewDidAppear(_ animated: Bool) {
		let statusMic = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
		let statusSpeech = SFSpeechRecognizer.authorizationStatus()

		if statusMic != AVAuthorizationStatus.authorized {
			OperationQueue.main.addOperation {
				let alert =	UIAlertController(title: "マイク使用不可",
				           	                  message: "[設定]にてマイクの使用を許可してください。",
				           	                  preferredStyle: .alert)
				let action = UIAlertAction(title: "OK", style: .default, handler: nil)
				alert.addAction(action)
				self.present(alert, animated: true, completion: nil)
			}
		}
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
		items.removeAll()
		mainTable.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	@IBAction func pushUpload(_ sender: Any) {

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
		let fromPos: CGPoint = recordButton.frame.origin
		let toPos: CGPoint = CGPoint(x: fromPos.x + size.width * 0.125,
		                             y: fromPos.y + size.width * 0.125 + size.height * 0.25)

		UIView.animate(withDuration: 1.0, animations: {
			self.recordButton.frame = CGRect(x: toPos.x, y: toPos.y,
			                                 width: size.width * 0.5, height: size.width * 0.5)
		}) { (finished) in

		}
	}

	func addItemAnimation() {
		let count: Int = items.count < 7 ? items.count : 6
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
			if self.firstTime {
				self.uploadButton.isEnabled = true
				self.firstTime = false
			}
			let indexPath: IndexPath = IndexPath(row: 0, section: self.items.count - 1)
			self.mainTable.scrollToRow(at: indexPath, at: UITableViewScrollPosition.none, animated: true)
		}
	}

	func parser() -> [(String, Int)] {
		var results = [(String, Int)]()
		let pattern: String = "[1-9][0-9]*円"
		var str: String = sentence
		while true {
			let range: Range<String.Index>? = str.range(of: pattern,
			                                            options: .regularExpression,
			                                            range: str.startIndex ..< str.endIndex,
			                                            locale: .current)
			if range != nil {
				if str.startIndex < range!.lowerBound {
					let value: Int = Int(str[range!].replacingOccurrences(of: "円", with: ""))!
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
		return results
	}

	func appendItem() {
		let results: [(name: String, value: Int)] = parser()
		for result in results {
			items.append(Item(name: result.name, value: result.value))
		}
		mainTable.reloadData()

		if results.count > 0 {
			if firstTime {
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
		let cell = mainTable.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! mainCustomTableViewCell
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
	
}

