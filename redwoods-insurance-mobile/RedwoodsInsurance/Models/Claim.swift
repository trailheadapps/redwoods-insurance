//
//  Claim.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/9/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SwiftUI
import Combine

struct Claim: Hashable, Identifiable, Decodable {
  var id: String
  var subject: String
  var caseNumber: String

  static func generateDemoClaims(numberOfClaims: Int) -> [Claim] {
    var demoClaims = [Claim]()
    for indexCounter in 1...numberOfClaims {
      demoClaims.append(
        Claim(id: "PRE1234\(indexCounter)",
          subject: "Demo Subject - \(indexCounter)",
          caseNumber: String(Int.random(in: 0 ..< 1000000)))
      )
    }
    return demoClaims
  }

  static func fromJson(record: RestClient.SalesforceRecord) -> Claim {
    return .init(
      id: record["Id"] as? String ?? "9999999",
      subject: record["Subject"] as? String ?? "None Listed",
      caseNumber: record["CaseNumber"] as? String ?? "0"
    )
  }

}
