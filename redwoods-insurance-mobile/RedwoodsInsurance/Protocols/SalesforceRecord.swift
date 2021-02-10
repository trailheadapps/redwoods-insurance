//
//  SalesforceRecord.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/6/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore

protocol SalesforceRecord {

}

extension SalesforceRecord {
  var asSalesforceRecord: RestClient.SalesforceRecord {
    /// badKeys is an array of keys that are internal to the SalesforceRecord
    /// object but are not valid Salesforce fields.
    let badKeys = ["index"]
    let mirror = Mirror(reflecting: self)
    let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy
    /// Filter out bad keys.
    .filter {
      guard let label = $0.label else {return false}
      return !badKeys.contains(label)
    }
    /// map over remaining items in the struct, creating a dict from properties
    .map({ (label: String?, value: Any) -> (String, Any)? in
      guard let label = label else { return nil }
      return (label, value)
    }).compactMap { $0 })
    return dict
  }
}
