//
//  ContactPickerViewModel.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import Contacts
import Combine
import UIKit

class ContactPickerViewModel: ObservableObject {

  @Published var allContacts: [CNContact] = []

  let contactsStore = CNContactStore()
  private var cancellables = Set<AnyCancellable>()

  let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactPhoneNumbersKey,
              CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactImageDataKey,
              CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey,
              CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as! [CNKeyDescriptor] // swiftlint:disable:this force_cast

  func requestPermission() -> Future<Bool, Error> {
    return Future<Bool, Error> { promise in
      self.contactsStore.requestAccess(for: .contacts) { granted, error in
        guard granted else {
          return promise(.failure(error!))
        }
        return promise(.success(granted))
      }
    }
  }

  func fetchContacts() {
    requestPermission()
      .receive(on: RunLoop.main)
      .map { _ -> [CNContact] in
        var retrieved = [CNContact]()
        let fetchRequest = CNContactFetchRequest(keysToFetch: self.keys)
        fetchRequest.sortOrder = CNContactSortOrder.userDefault

        do {
          let containerId = self.contactsStore.defaultContainerIdentifier()
          let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
          retrieved = try self.contactsStore.unifiedContacts(matching: predicate, keysToFetch: self.keys as [CNKeyDescriptor])
        } catch let error as NSError {
          print(error.localizedDescription)
        }
        return retrieved
      }
      .mapError { dump($0) }
      .replaceError(with: [])
      .map {$0}
      .assign(to: \.allContacts, on: self)
      .store(in: &cancellables)

  }

  func getSelectedContactsById(selected: Set<String>) -> [CNContact] {
    var contacts: [CNContact] = []
    for id in selected {
      if let contact = self.allContacts.first(where: {$0.id == id}) {
        contacts.append(contact)
      }
    }
    return contacts
  }
}
