//
//  AudioRecorder.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/27/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import Speech

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

  let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
  var audioRecorder: AVAudioRecorder!
  var audioPlayer: AVAudioPlayer!
  var meterTimer: Timer?
  let recordingSession = AVAudioSession.sharedInstance()
  let avSessionSettings = [
    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
    AVSampleRateKey: 12000,
    AVNumberOfChannelsKey: 1,
    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
  ]

  var newClaim: NewClaimModel?

  var playbackDisabled = true {
    didSet {
      objectWillChange.send(self)
    }
  }

  var recordingDisabled = true {
    didSet {
      objectWillChange.send(self)
    }
  }

  var isPlaying = false {
    didSet {
      objectWillChange.send(self)
    }
  }

  var recordButtonLabel = "Record" {
    didSet {
      objectWillChange.send(self)
    }
  }
  var recording = false {
    didSet {
      objectWillChange.send(self)
    }
  }

  var transcribedText = "" {
    didSet {
      objectWillChange.send(self)
    }
  }

  var meterTimerText = "00:00:00" {
    didSet {
      objectWillChange.send(self)
    }
  }

  func setupAudioRecorder() {
    do {
      let category = AVAudioSession.Category.playAndRecord
      try recordingSession.setCategory(category)
      try recordingSession.setActive(true)
      recordingSession.requestRecordPermission { _ in
        DispatchQueue.main.async {
          // requestRecordPermission will ask the user for permission to record.
          // in this block we should do something kind to the user when they say no.
          // tbd.
        }
      }
    } catch {
      print("failed to record")
    }
  }

  func updateTimerText() {
    if self.audioRecorder.isRecording {
      let hour = Int((self.audioRecorder.currentTime / 60) / 60)
      let minute = Int(self.audioRecorder.currentTime / 60)
      let second = Int(self.audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
      let totalTimeString = String(format: "%02d:%02d:%02d", hour, minute, second)
      self.meterTimerText = totalTimeString
    }
  }

  func startTimer() {
    self.meterTimer?.invalidate()
    self.meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      self.updateTimerText()
    }
  }

  func stopTimer() {
    self.updateTimerText()
    self.meterTimer?.invalidate()
  }

  func startRecording() {
    do {
      audioRecorder = try AVAudioRecorder(url: audioFilenameURL, settings: avSessionSettings)
      audioRecorder.delegate = self
      audioRecorder?.record()
      self.transcribedText = "Recording..."
      startTimer()
      recording = true
    } catch {
      finishRecording(success: false)
    }
  }

  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    print("audioRecorder finished")
    if !flag {
      finishRecording(success: false)
    }
  }

  func finishRecording(success: Bool) {
    audioRecorder.stop()
    stopTimer()
    processTextFrom(audioURL: audioFilenameURL)
    if success {
      recording = false
      playbackDisabled = false
    } else {
      recording = false
    }
  }

  func processTextFrom(audioURL: URL) {
    transcribedText = "Transcribing..."
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    let request = SFSpeechURLRecognitionRequest(url: audioURL)

    request.shouldReportPartialResults = true

    if (recognizer?.isAvailable)! {
      recognizer?.recognitionTask(with: request) { [unowned self] result, error in
        guard error == nil else { print("Error: \(error!)"); return }
        guard let result = result else { print("No result!"); return }
        print("hmm, recognizing finished?")

        if result.isFinal {
          self.newClaim?.transcribedText = result.bestTranscription.formattedString
          self.transcribedText = result.bestTranscription.formattedString
        }

      }
    } else {
      print("Device doesn't support speech recognition")
    }
    print("testing stop here")
  }

  func prepAudioPlayer() {
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
      let audioData: Data = try Data(contentsOf: audioFilenameURL)
      return audioData
    } catch {
      print("Unable to load audio file")
    }
    return nil
  }

  func toggleAudio() {
    if isPlaying {
      audioPlayer.stop()
      recordingDisabled = false
      isPlaying = false
    } else {
      if FileManager.default.fileExists(atPath: audioFilenameURL.path) {
        recordingDisabled = true
        prepAudioPlayer()
        audioPlayer.play()
        isPlaying = true
      } else {
        print("Audio file is not present at \(audioFilenameURL.path)")
      }
    }
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    recordingDisabled = false
    isPlaying = false
  }
  /// Returns the URL at which the recorded audio will be temporarily saved
  /// for the new claim.
  var audioFilenameURL: URL {
    do {
      let documentsURL = try FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      return documentsURL.appendingPathComponent("incident.m4a")
    } catch {
      print("unable to get documents URL")
    }
    return URL(fileURLWithPath: "")
  }

}
