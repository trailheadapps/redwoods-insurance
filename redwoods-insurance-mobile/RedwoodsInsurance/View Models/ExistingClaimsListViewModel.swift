//
//  ExistingClaimsListViewModel.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 10/29/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import Combine

class ExistingClaimsListViewModel: ObservableObject {
  @Published var claims = [Claim]()// RestClient.QueryResponse<Claim> = RestClient.QueryResponse<Claim>.getInstance(records: [Claim]())

  private var cancellables = Set<AnyCancellable>()

  let existingClaimQuery = "SELECT Id, Subject, CaseNumber FROM Case WHERE Status != 'Closed' ORDER BY CaseNumber DESC"

  func fetchDataFromSalesforce() async {

    let request = RestClient.shared.request(forQuery: existingClaimQuery, apiVersion: RestClient.apiVersion)

    async let casesData: [Claim] = RestClient.shared.fetchSalesforceRecords(restRequest: request)
    do {
      claims = try await casesData
    } catch {
      print(error.localizedDescription)
    }

//    RestClient.shared.records(forRequest: request)
//      .receive(on: RunLoop.main)
//      .assign(to: \.claims, on: self)
//      .store(in: &cancellables)

  }
}
