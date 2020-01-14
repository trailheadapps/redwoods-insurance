//
//  ExistingClaimsListModel.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/9/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SwiftUI
import Combine

class ExistingClaimsListModel: ObservableObject {
  
  @Published var claims: [Claim] = []
  private var caseCancellable: AnyCancellable?

  
  let existingClaimQuery = "SELECT Id, Subject, CaseNumber FROM Case WHERE Status != 'Closed' ORDER BY CaseNumber DESC"
  
  func fetchDataFromSalesforce(){
    let requestForOpenCases = RestClient.shared.request(forQuery: existingClaimQuery, apiVersion: RestClient.apiVersion)
    caseCancellable = RestClient.shared
      .publisher(for: requestForOpenCases)
      .receive(on: RunLoop.main)
      .tryMap({restresponse -> [String:Any] in
        print(restresponse)
        let json = try restresponse.asJson() as? [String: Any]
        print(json)
        return json ?? [:]
      })
      .map({json -> RestClient.SalesforceRecords in
        let records = json["records"] as? RestClient.SalesforceRecords
        return records ?? [[:]]
      })
      .map({
        $0.map{(item) -> Claim in
          return Claim(
            id: item["Id"] as? String ?? "None Listed",
            subject: item["Subject"] as? String ?? "None Listed",
            caseNumber: item["CaseNumber"] as? String ?? "0"
          )
        }
      })
      .mapError{error -> Error in
        print(error)
        return error
    }
      .catch{ error in
        
        return Just([])
      }
    .assign(to: \ExistingClaimsListModel.claims, on: self)
  }
}
