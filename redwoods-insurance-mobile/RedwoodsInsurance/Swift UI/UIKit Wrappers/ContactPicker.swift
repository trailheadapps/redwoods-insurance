//
//  ContactPicker.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactPicker: View {
  @StateObject private var contactPickerViewModel = ContactPickerViewModel()
  @ObservedObject var newClaimViewModel: NewClaimViewModel
  @State private var selected = Set<String>()
  @Binding var isShowingContactPicker: Bool

  var body: some View {
    NavigationView {
      List(contactPickerViewModel.allContacts, selection: $selected) { contact in
        ContactListRowComponent(contact: contact)
      }
      .navigationBarItems(trailing:
        Button("Done") {
          self.newClaimViewModel.selectedContacts = contactPickerViewModel.getSelectedContactsById(selected: self.selected)
          self.isShowingContactPicker = false
        }
      )
      .environment(\.editMode, .constant(EditMode.active))
      .navigationBarTitle(Text("Selected Contacts \(selected.count)"))
    }
    .onAppear {
      self.contactPickerViewModel.fetchContacts()
    }
  }
}

struct ContactPicker_Previews: PreviewProvider {
  static var previews: some View {
    let newClaimViewModel = NewClaimViewModel()
    ContactPicker(newClaimViewModel: newClaimViewModel, isShowingContactPicker: .constant(false))
  }
}
