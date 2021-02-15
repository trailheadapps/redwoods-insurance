//
//  CNContactExtensions.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/6/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import Contacts

extension CNContact: Identifiable {
  public var id: String { identifier }
}
