//
//  ContactListRow.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/28/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import ContactsUI

struct ContactListRow: View {

  var contact: CNContact
  @EnvironmentObject var newClaim: NewClaimModel

  var body: some View {
    HStack {
      if contact.imageDataAvailable {
        Image(uiImage: UIImage(data: contact.thumbnailImageData!)!)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .scaledToFit()
      }
      VStack {
        Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "")
        Text(contact.phoneNumbers.first?.value.stringValue ?? "" as String)
      }
    }
    .frame(height: 50.0)
  }
}

struct ContactListRow_Previews: PreviewProvider {

  static var contact = CNContact()
  init() {
    let newContact = CNMutableContact()
    let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: "555 555 5555"))
    newContact.phoneNumbers = [homePhone]
    newContact.familyName = "Test"
    newContact.givenName = "Bob"
    ContactListRow_Previews.contact = newContact
  }

  static var previews: some View {
    ContactListRow(contact: self.contact)
  }

}
