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
  let id: String
  let subject: String
  let caseNumber: String
  
  static func generateDemoClaims(numberOfClaims: Int) -> [Claim] {
    var demoClaims = [Claim]()
    for idx in 1...numberOfClaims {
      demoClaims.append(
        Claim(id: "PRE1234\(idx)", subject: "Demo Subject - \(idx)", caseNumber: String(Int.random(in: 0 ..< 1000000)))
      )
    }
    return demoClaims
  }
  
}
