//
//  ClaimDetails.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/10/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI

struct ClaimDetails: View {
  let activeClaimId: String
  @ObservedObject var viewModel = ClaimDetialsViewModel()

  var body: some View {
    List(viewModel.claimDetails) { row in
      VStack(alignment: .leading, spacing: 3) {
        Text(row.value)
        Text(row.key).font(.subheadline).italic()
      }
    }
    .onAppear {
      self.viewModel.fetchClaimDetailsFromSalesforce(caseId: self.activeClaimId)
    }
  }
}

struct ClaimDetails_Previews: PreviewProvider {
  static var previews: some View {
    ClaimDetails(activeClaimId: "1234")
  }
}
