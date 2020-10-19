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

  func fetchDataFromSalesforce() {
    caseCancellable = RestClient.shared.records(fromQuery: existingClaimQuery, returningModel: Claim.fromJson(record:))
      .receive(on: RunLoop.main)
      .map {$0}
      .assign(to: \.claims, on: self)
  }
}

struct ExistingClaimsListModel_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
