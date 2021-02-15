//
//  Contact.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SwiftUI
import Combine

struct User: Identifiable, Decodable {
  struct Contact: Identifiable, Decodable {
    enum CodingKeys: String, CodingKey {
      case id = "Id"
      case accountId = "AccountId"
    }
    var id: String
    var accountId: String

  }

  enum CodingKeys: String, CodingKey {
    case id = "Id"
    case contact = "Contact"
  }

  var id: String
  var contact: User.Contact

}
