//
//  PartiesInvolvedCmp.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/15/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import ContactsUI

struct PartiesInvolvedCmp: View {
  
  @State var showingContactPicker = false
  @State var selectedContacts: [CNContact]  = []
  @EnvironmentObject var newClaim: NewClaimModel
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Parties Involved").font(.headline).padding(.leading)
        Spacer()
        Button("Edit") {
          self.showingContactPicker = true
        }.padding(.trailing)
      }
      List(newClaim.selectedContacts) { contact in
        ContactListRow(contact: contact)
      }
    }
    .sheet(isPresented: $showingContactPicker) {
      ContactPicker(selectedContacts: self.$selectedContacts, sheetDisplayed: self.$showingContactPicker )
        .onDisappear {
          print("closing sheet")
          self.newClaim.selectedContacts = self.selectedContacts
      }
    }
  }
}

struct PartiesInvolvedCmp_Previews: PreviewProvider {
  static var previews: some View {
    PartiesInvolvedCmp().environmentObject(NewClaimModel())
  }
}
