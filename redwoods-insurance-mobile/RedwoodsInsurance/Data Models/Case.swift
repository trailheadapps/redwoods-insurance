//
//  Case.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 11/4/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore

struct Case: Encodable, SalesforceRecord {
  var origin: String = "Redwoods Insurance Mobile App"
  var status: String = "new"
  var subject: String
  var description: String
  var type: String = "Car Insurance"
  var reason: String = "Vehicle Incident"
  var Incident_Location_Txt__c: String
  var Incident_Location__latitude__s: Double
  var Incident_Location__longitude__s: Double
  var PotentialLiability__c: Bool = true

}
