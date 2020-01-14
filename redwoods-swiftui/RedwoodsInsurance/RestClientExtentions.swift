//
//  RestClientExtentions.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/9/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore

extension RestClient {
  static let apiVersion = "v47.0"

  typealias JsonKeyValues = [String:Any]
  typealias SalesforceRecord = [String:Any]
  typealias SalesforceRecords = [SalesforceRecord]
}
