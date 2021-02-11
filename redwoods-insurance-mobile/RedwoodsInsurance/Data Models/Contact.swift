//
//  Contact.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/6/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import ContactsUI
import SalesforceSDKCore

struct Contact: Encodable, SalesforceRecord {
  var firstName: String
  var lastName: String
  var phone: String
  var email: String
  var mailingStreet: String
  var mailingCity: String
  var mailingState: String
  var mailingPostalCode: String
  var mailingCountry: String
  var index: Int

  init(contact: CNContact, index: Int) {
    let address = contact.postalAddresses.first
    self.firstName = contact.givenName
    self.lastName = contact.familyName.isEmpty ? "No last name given" : contact.familyName
    self.phone = contact.phoneNumbers.first?.value.stringValue ?? ""
    self.email = (contact.emailAddresses.first?.value as String?) ?? ""
    self.mailingStreet = address?.value.state ?? ""
    self.mailingCity = address?.value.city ?? ""
    self.mailingState = address?.value.state ?? ""
    self.mailingPostalCode = address?.value.postalCode ?? ""
    self.mailingCountry = address?.value.country ?? ""
    self.index = index
  }

  var associationRecord: RestClient.SalesforceRecord {
    return  [
      "Case__c": "@{refCase.id}",
      "Contact__c": "@{contact\(index).id}"
    ]
  }
}
