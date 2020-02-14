//
//  ClaimDetailsViewModel.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/13/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SwiftUI
import Combine

struct ClaimDetailsModel: Identifiable, Hashable, Decodable {
  var id: UUID
  var key: String
  var value: String

  static func fromJson(record: [String:Any]) -> ClaimDetailsModel {
    return .init(
      id: UUID(),
      key: record.keys.first!,
      value: record.values.first as! String
    )
  }

  static func fromTupple(_ tupple: (key:String, value:String)) -> ClaimDetailsModel {
    return .init(
      id: UUID(),
      key: tupple.key,
      value: tupple.value
    )
  }
}

class ClaimDetialsViewModel: ObservableObject {

  private var claimDetailRecords: RestClient.SalesforceRecords = []
  private var claimDetailCancellable: AnyCancellable?
  @Published var claimDetails: [ClaimDetailsModel] = []

  func fetchClaimDetailsFromSalesforce(caseId: String) {
    claimDetailCancellable = RestClient.shared.fetchData(fromLayout: "Compact", for: caseId)
      .print("claimDetails: ")
      .receive(on: RunLoop.main)
      .sink { records in
        var temp = [ClaimDetailsModel]()
        for record in records {
          temp.append(ClaimDetailsModel.fromJson(record: record))
        }
        self.claimDetails = temp
      }
//      .assign(to: \.claimDetailRecords, on: self)
  }

}
