//
//  ContactListRowComponent.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import ContactsUI

struct ContactListRowComponent: View {

  var contact: CNContact

  var body: some View {
    HStack {
      if contact.imageDataAvailable {
        Image(uiImage: UIImage(data: contact.thumbnailImageData!)!)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .scaledToFit()
      }
      VStack {
        Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "No name given")
        Text(contact.phoneNumbers.first?.value.stringValue ?? "No phone number given" as String)
      }
    }.frame(height: 50.0)
  }
}

struct ContactListRowComponent_Previews: PreviewProvider {

  static var contact = CNContact()
  init() {
    let newContact = CNMutableContact()
    let homePhone = CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: "555 555 5555"))
    newContact.phoneNumbers = [homePhone]
    newContact.familyName = "Test"
    newContact.givenName = "Bob"
    ContactListRowComponent_Previews.contact = newContact
  }

  static var previews: some View {
    ContactListRowComponent(contact: self.contact)
  }
}
