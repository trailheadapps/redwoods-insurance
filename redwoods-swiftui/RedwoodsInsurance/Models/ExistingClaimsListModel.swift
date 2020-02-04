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
    caseCancellable = RestClient.shared.records(fromQuery: existingClaimQuery, returningModel: Claim.fromJson(record:))
      .receive(on: RunLoop.main)
      .map{$0}
      .assign(to: \.claims, on: self)
    
//
//    let requestForOpenCases = RestClient.shared.request(forQuery: existingClaimQuery, apiVersion: RestClient.apiVersion)
//    caseCancellable = RestClient.shared
//      .publisher(for: requestForOpenCases)
//      .receive(on: RunLoop.main)
//      .tryMap({restresponse -> RestClient.JSONKeyValuePairs in
//        let json = try restresponse.asJson() as? RestClient.JSONKeyValuePairs
//        return json ?? RestClient.JSONKeyValuePairs()
//      })
//      .map({json -> RestClient.SalesforceRecords in
//        let records = json["records"] as? RestClient.SalesforceRecords
//        return records ?? [[:]]
//      })
//      .map({
//        $0.map{(item) -> Claim in
//          return Claim(
//            id: item["Id"] as? String ?? "None Listed",
//            subject: item["Subject"] as? String ?? "None Listed",
//            caseNumber: item["CaseNumber"] as? String ?? "0"
//          )
//        }
//      })
//      .mapError{error -> Error in
//        print(error)
//        return error
//      }
//      .catch{ error in
//        return Just([])
//      }
//    .assign(to: \ExistingClaimsListModel.claims, on: self)
  }
}
