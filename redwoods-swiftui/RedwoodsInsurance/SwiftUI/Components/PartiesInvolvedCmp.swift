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
//  @State var selectedContacts: [CNContact]
  @EnvironmentObject var newClaim: NewClaimModel
  
  var body: some View {
    VStack(alignment: .leading){
      HStack{
        Text("Parties Involved").font(.headline).padding(.leading)
        Spacer()
        Button(action: {
          self.showingContactPicker = true
        }) {
          Text("Edit")
        }.padding(.trailing)
      }
      List(newClaim.contacts, id: \.self) { contact in
        ContactListRow(contact: contact)
      }
//      List(self.newClaim.contacts.indices, id: \.self ){ idx in
//        ContactListRow(contact: self.newClaim.contacts[idx])
//      }
    }.sheet(isPresented: $showingContactPicker){
      EmbeddedContactPicker()
    }
  }
}

struct PartiesInvolvedCmp_Previews: PreviewProvider {
    static var previews: some View {
      PartiesInvolvedCmp().environmentObject(NewClaimModel())
    }
}
