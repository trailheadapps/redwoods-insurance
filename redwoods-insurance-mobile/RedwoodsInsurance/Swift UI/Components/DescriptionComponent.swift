//
//  DescriptionComponent.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 10/30/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import Foundation

struct DescriptionComponent: View {
  @ObservedObject var newClaimViewModel: NewClaimViewModel

  var body: some View {
    VStack(alignment: .leading) {
      Text("Description of incident").font(.headline).padding(.leading)
      AudioTranscriptionComponent(newClaimViewModel: self.newClaimViewModel)
      TextEditor(text: self.$newClaimViewModel.incidentDescription)
    }
    .frame(height: 200.0)

  }
}

struct DescriptionComponent_Previews: PreviewProvider {
  static var previews: some View {
    let newClaimViewModel = NewClaimViewModel()
    DescriptionComponent(newClaimViewModel: newClaimViewModel)
  }
}
