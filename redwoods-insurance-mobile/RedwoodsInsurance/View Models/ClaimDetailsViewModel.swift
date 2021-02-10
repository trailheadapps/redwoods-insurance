//
//  ClaimDetailsViewModel.swift
//  Redwoods
//
//  Created by Kevin Poorman on 10/22/20.
//  Copyright © 2020 RedwoodsOrganizationName. All rights reserved.
//

import Foundation
import Combine
import SalesforceSDKCore

class ClaimDetialsViewModel: ObservableObject {

  private var claimDetailRecords: RestClient.SalesforceRecords = []
  private var cancellables = Set<AnyCancellable>()

  @Published var claimDetails: [ClaimDetailsDataModel] = []

  func fetchClaimDetailsFromSalesforce(caseId: String) {
    RestClient.shared.fetchData(fromLayout: "Compact", for: caseId)
      .receive(on: RunLoop.main)
      .sink { records in
        var temp = [ClaimDetailsDataModel]()
        for record in records {
          temp.append(ClaimDetailsDataModel.fromJson(record: record))
        }
        self.claimDetails = temp
      }.store(in: &cancellables)
  }

}
