//
//  ExistingClaims.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/9/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import Combine
import SalesforceSDKCore

struct ExistingClaims: View {
  @ObservedObject var viewModel = ExistingClaimsListModel()
  
  var body: some View {
    NavigationView{
      List(viewModel.claims) { dataItem in
        NavigationLink(destination: ClaimDetails()){
          HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 3) {
              Text(dataItem.subject)
              Text(String(dataItem.caseNumber)).font(.subheadline).italic()
            }
          }
        }
      }
      // Navigation Bar
      .navigationBarTitle(Text("Exisitng Claims"), displayMode: .inline)
      // Navigation bar button
      .navigationBarItems(
        leading: Button("Logout") {
          self.viewModel.claims = []
          UserAccountManager.shared.logout()
        },
        trailing: NavigationLink(destination: NewClaim()) {
          Image(systemName: "plus")
        }
      )
    }
    .onAppear{
      self.viewModel.fetchDataFromSalesforce()
    }
  }
}

struct RootUI_Previews: PreviewProvider {
  static var previews: some View {
    let preview = ExistingClaims()
    preview.viewModel.claims = Claim.generateDemoClaims(numberOfClaims: 5)
    return preview
  }
}
