//
//  NewClaimCtrl+AVFoundation.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/29/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import AVFoundation
import Speech
import UIKit

extension NewClaimCtrl: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
	// Computed Property that acts like a stored property
	var audioFilenameURL: URL {
		get {
			// we're always going to reuse the same audiofile url
			return FileManager.getDocumentsDir().appendingPathComponent("incident.m4a")
		}
	}

	func initAVRecordingExtension() {
		recordingSession = AVAudioSession.sharedInstance()
		playButton.isEnabled = false
		
		self.transcriptionText.layer.borderWidth = 1
		self.transcriptionText.layer.borderColor = UIColor.black.cgColor

		do {
			try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker )
			try recordingSession.setActive(true)
			recordingSession.requestRecordPermission() { _ in
				//[unowned self] allowed in
				DispatchQueue.main.async {
					// requestRecordPermission will ask the user for permission to record.
					// in this block we should do something kind to the user when they say no.
					// tbd.
				}
			}
		} catch {
			print("failed to record")
		}
		// attach a dismiss button to the keyboard, in case a user taps on the field, instead of using dictation
		attachKeyboardDismissalButton()
	}
	
	func attachKeyboardDismissalButton(){
		let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(NewClaimCtrl.doneButtonAction))
		toolbar.setItems([flexSpace, doneButton], animated: false)
		toolbar.sizeToFit()
		//setting toolbar as inputAccessoryView
		self.transcriptionText.inputAccessoryView = toolbar
	}
	
	@objc func doneButtonAction() {
		self.view.endEditing(true)
	}
	
	@IBAction func onStartOrStopRecordingTouched() {
		if incidentRecorder == nil {
			startRecording()
		} else {
			finishRecording(success: true)
		}
	}
	
	func startRecording() {
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 12000,
			AVNumberOfChannelsKey: 1,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		]
		
		do {
			incidentRecorder = try AVAudioRecorder(url: audioFilenameURL, settings: settings)
			incidentRecorder.delegate = self
			incidentRecorder.record()
			meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
			
			recordButton.setTitle("Tap to Stop", for: .normal)
		} catch {
			finishRecording(success: false)
		}
	}
	
	func finishRecording(success: Bool) {
		incidentRecorder.stop()
		incidentRecorder = nil
		
		processTextFrom(audioURL: audioFilenameURL)
		meterTimer.invalidate()
		
		if success {
			recordButton.setTitle("Tap to Re-record", for: .normal)
			playButton.isEnabled = true
		} else {
			recordButton.setTitle("Tap to Record", for: .normal)
			// recording failed :(
		}
	}
	
	@objc func updateAudioMeter(timer: Timer){
		if incidentRecorder != nil && incidentRecorder.isRecording {
			let hr = Int((incidentRecorder.currentTime / 60) / 60)
			let min = Int(incidentRecorder.currentTime / 60)
			let sec = Int(incidentRecorder.currentTime.truncatingRemainder(dividingBy: 60))
			let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
			recordingTimerLabel.text = totalTimeString
			incidentRecorder.updateMeters()
		}
	}
	
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		if !flag {
			finishRecording(success: false)
		}
	}
	
	func processTextFrom(audioURL: URL) {
		let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
		let request = SFSpeechURLRecognitionRequest(url: audioURL)
		
		request.shouldReportPartialResults = true
		
		if (recognizer?.isAvailable)! {
			recognizer?.recognitionTask(with: request) { [unowned self] result, error in
				guard error == nil else { print("Error: \(error!)"); return }
				guard let result = result else { print("No result!"); return }
				self.transcriptionText.text = result.bestTranscription.formattedString
				self.transcribedText = result.bestTranscription.formattedString
			}
		} else {
			print("Device doesn't support speech recognition")
		}
	}
	
	func prepareToPlay(){
		do {
			audioPlayer = try AVAudioPlayer(contentsOf: audioFilenameURL)
			audioPlayer.delegate = self
			audioPlayer.prepareToPlay()
		} catch {
			print("Unable to prepare to play audio")
		}
	}
	
	func audioFileAsData() -> Data? {
		do {
			let audioData:Data = try Data(contentsOf: audioFilenameURL)
			return audioData
		} catch {
			print("unable to load audio file")
		}
		return nil
	}
	
	@IBAction func playAudio(_ sender: Any){
		if(isPlaying){
			audioPlayer.stop()
			recordButton.isEnabled = true
			playButton.isEnabled = false
			isPlaying = false
		} else {
			if FileManager.default.fileExists(atPath: audioFilenameURL.path) {
				recordButton.isEnabled = false
				playButton.setTitle("pause", for: .normal)
				prepareToPlay()
				audioPlayer.play()
				isPlaying = true
			} else {
				print("Audio file is not present at \(audioFilenameURL.absoluteString)")
			}
		}
	}
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		recordButton.isEnabled = true
	}
	
}
