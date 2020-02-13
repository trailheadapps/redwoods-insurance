//
//  DescriptionCmp.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/15/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import AVFoundation

struct DescriptionCmp: View {
  @EnvironmentObject var newClaim: NewClaimModel
  @ObservedObject var audioRecorder = AudioRecorder()

  let recordingSession = AVAudioSession.sharedInstance()

  var body: some View {
    audioRecorder.newClaim = newClaim
    return VStack(alignment: .leading) {
      Text("Description of incident").font(.headline).padding(.leading)
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
          Button(action: {self.audioRecorder.startRecording()}) {
            Text(self.audioRecorder.recordButtonLabel)
          }.padding(.trailing)
            .disabled(self.audioRecorder.isPlaying)
        } else {
          Button(action: {
            self.audioRecorder.finishRecording(success: true)
            if let audioData = self.audioRecorder.audioFileAsData() {
              self.newClaim.audioData = audioData
            }
          }) {
            Text("Stop")
          }.padding(.trailing)
        }
      }
      MultiLineTextField("Enter description or press Record for voice transcription", text: self.$audioRecorder.transcribedText, onCommit: {
        print("Final Text: \(self.$audioRecorder.transcribedText)")
        self.newClaim.transcribedText = self.audioRecorder.transcribedText
      }).overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black))
        .padding(.horizontal)
    }
    .onAppear {
      self.audioRecorder.setupAudioRecorder()
    }
  }
}

struct DescriptionCmp_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionCmp()
    }
}
