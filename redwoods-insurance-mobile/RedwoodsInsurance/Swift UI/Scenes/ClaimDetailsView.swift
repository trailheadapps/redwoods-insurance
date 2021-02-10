//
//  ClaimDetailsView.swift
//  Redwoods
//
//  Created by Kevin Poorman on 10/22/20.
//  Copyright © 2020 RedwoodsOrganizationName. All rights reserved.
//

import SwiftUI

struct ClaimDetailsView: View {
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

struct ClaimDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    ClaimDetailsView(activeClaimId: "1234")
  }
}
