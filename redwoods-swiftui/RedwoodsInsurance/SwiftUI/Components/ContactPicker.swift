//
//  ContactPicker.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/4/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactPicker: View {
  @ObservedObject var contactsModel = ContactsPickerViewModel()
  @Binding var selectedContacts: [CNContact]
  @State var selected = Set<String>()
  @Binding var sheetDisplayed: Bool
  @State var editMode: EditMode = .active

  var body: some View {
   NavigationView {
      List(contactsModel.allContacts, selection: $selected) { contact in
        ContactListRow(contact: contact)
      }
      .navigationBarItems(trailing:
        Button("Done") {
          self.selectedContacts = self.getSelectedContactsById()
          self.sheetDisplayed = false
        })
      .environment(\.editMode, .constant(EditMode.active))
      .navigationBarTitle(Text("Select Contacts \(selected.count)"))
    }
    .onAppear {
      self.contactsModel.fetchContacts()
    }
  }

  func getSelectedContactsById() -> [CNContact] {
    var contacts: [CNContact] = []
    for id in selected {
      if let contact = contactsModel.allContacts.first(where: {$0.id == id}) {
        contacts.append(contact)
      }
    }
    return contacts
  }

}

struct ContactPicker_Previews: PreviewProvider {
    static var previews: some View {
      ContactPicker(selectedContacts: .constant([]), sheetDisplayed: .constant(false))
    }
}
