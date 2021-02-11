//
//  NewClaimView.swift
//  Redwoods
//
//  Created by Kevin Poorman on 10/22/20.
//  Copyright © 2020 RedwoodsOrganizationName. All rights reserved.
//

import SwiftUI
import Combine

struct NewClaimView: View {
  @StateObject var newClaim = NewClaimViewModel()
  @Environment(\.presentationMode) var mode: Binding<PresentationMode>

  var body: some View {
    ZStack {
      if self.newClaim.showActivityIndicator {
        UploadingProgressViewComponet()
      }

      ScrollView {
        VStack {
          IncidentLocationComponent(newClaimViewModel: self.newClaim)
          DescriptionComponent(newClaimViewModel: self.newClaim)
          PhotoSelectionAndDisplayComponent(newClaimViewModel: self.newClaim)
          PartiesInvolvedComponent(newClaimViewModel: self.newClaim)
          .navigationBarItems(
            trailing: Button("Submit") {
              print("Submitting")
              self.newClaim.showActivityIndicator = true
              self.newClaim.uploadClaimToSalesforce()
                .sink { _ in
                  self.newClaim.showActivityIndicator = false
                  self.mode.wrappedValue.dismiss()
                }
                .store(in: &newClaim.cancellables)
            }
          )
        }
      }
    }

  }
}

struct NewClaimView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NewClaimView()
    }
  }
}
