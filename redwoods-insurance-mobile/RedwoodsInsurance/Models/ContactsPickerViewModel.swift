//
//  ContactsPickerViewModel.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/4/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import Contacts
import Combine
import UIKit

class ContactsPickerViewModel: ObservableObject {

  @Published var allContacts: [CNContact] = []

  let store = CNContactStore()
  private var retrieveCancellable: AnyCancellable?

  func requestPermission() -> Future<Bool, Error> {
    return Future<Bool, Error> { promise in
      self.store.requestAccess(for: .contacts) { granted, error in
        guard granted else {
          return promise(.failure(error!))
        }
        return promise(.success(granted))
      }
    }
  }

  func fetchContacts() {
    retrieveCancellable = requestPermission()
      .receive(on: RunLoop.main)
      .map { _ -> [CNContact] in
        var retrieved = [CNContact]()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactImageDataKey,
                    CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey,
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as! [CNKeyDescriptor] // swiftlint:disable:this force_cast

        let fetchRequest = CNContactFetchRequest(keysToFetch: keys )
        fetchRequest.sortOrder = CNContactSortOrder.userDefault

        do {
          let containerId = self.store.defaultContainerIdentifier()
          let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
          retrieved = try self.store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
        } catch let error as NSError {
          print(error.localizedDescription)
        }
        return retrieved
    }
    .mapError { dump($0) }
    .replaceError(with: [])
    .map({$0})
    .assign(to: \.allContacts, on: self)

  }

}
