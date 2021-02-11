//
//  AudioTranscriptionComponent.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 10/30/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AudioTranscriptionComponent: View {
  @StateObject var audioRecorder = AudioTranscriptionViewModel()
  @ObservedObject var newClaimViewModel: NewClaimViewModel

  let recordingSession = AVAudioSession.sharedInstance()
  var body: some View {
    HStack {
      Text("\(self.audioRecorder.meterTimerText)")
        .padding(.leading)
      Spacer()
      Button("Play") {
        print("Play pressed")
        self.audioRecorder.toggleAudio()
      }.disabled(self.audioRecorder.playbackDisabled)
      Spacer()
      if audioRecorder.recording == false {
        Button(self.audioRecorder.recordButtonLabel) {
          self.audioRecorder.startRecording()
        }
        .padding(.trailing)
        .disabled(self.audioRecorder.isPlaying)
      } else {
        Button("Stop") {
          self.audioRecorder.finishRecording(success: true)
          if let audioData = self.audioRecorder.audioFileAsData() {
            self.newClaimViewModel.audioRecording = audioData
          }
        }.padding(.trailing)
      }
    }.onChange(of: self.$audioRecorder.transcribedText.wrappedValue) { newText in
      self.newClaimViewModel.incidentDescription = newText
    }
  }
}

struct AudioTranscriptionComponent_Previews: PreviewProvider {
  static var previews: some View {
    let newClaimViewModel = NewClaimViewModel()
    AudioTranscriptionComponent(newClaimViewModel: newClaimViewModel)
  }
}
