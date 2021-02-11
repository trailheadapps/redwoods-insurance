//
//  PartiesInvolvedComponent.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct PartiesInvolvedComponent: View {
  @State private var isShowingContactPicker = false
  @ObservedObject var newClaimViewModel: NewClaimViewModel

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Parties Involved").font(.headline).padding(.leading)
        Spacer()
        Button("Edit") {
          self.isShowingContactPicker = true
        }.padding(.trailing)
      }
      List(self.newClaimViewModel.selectedContacts) { contact in
        ContactListRowComponent(contact: contact)
      }
    }
    .sheet(isPresented: self.$isShowingContactPicker) {
      ContactPicker(newClaimViewModel: newClaimViewModel, isShowingContactPicker: self.$isShowingContactPicker)
    }.frame(height: 200.0)
  }
}

struct PartiesInvolvedComponent_Previews: PreviewProvider {
  static var previews: some View {
    let newClaimViewModel = NewClaimViewModel()
    PartiesInvolvedComponent(newClaimViewModel: newClaimViewModel)
  }
}
