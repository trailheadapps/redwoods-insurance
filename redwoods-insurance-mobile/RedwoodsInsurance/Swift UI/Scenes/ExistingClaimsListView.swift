//
//  ExistingClaimsView.swift
//  Redwoods
//
//  Created by Kevin Poorman on 10/22/20.
//  Copyright © 2020 RedwoodsOrganizationName. All rights reserved.
//

import SwiftUI
import Combine
import SalesforceSDKCore

struct ExistingClaimsListView: View {
  @ObservedObject var viewModel = ExistingClaimsListViewModel()

  var body: some View {
    NavigationView {
      List(viewModel.claims.records) { dataItem in
        NavigationLink(destination: ClaimDetailsView(activeClaimId: dataItem.id)) {
          HStack {
            VStack(alignment: .leading, spacing: 3) {
              Text(dataItem.subject)
              Text(String(dataItem.caseNumber)).font(.subheadline).italic()
            }
          }
        }
      }
      .listStyle(PlainListStyle())
      // Navigation Bar
      .navigationBarTitle(Text("Existing Claims"), displayMode: .inline)
      // Navigation bar button
      .navigationBarItems(
        leading: Button("Logout") {
          self.viewModel.claims.records = []
          UserAccountManager.shared.logout()
        },
        trailing: NavigationLink(
        destination: NewClaimView()) {
          HStack {
            Text("New ")
            Image(systemName: "plus")
          }
        }
      )
      .onAppear {
        print("On Appear firing for ExistingClaims()")
        self.viewModel.fetchDataFromSalesforce()
      }
      //        .onReceive(self.newClaim.completedPublisher) { _ in
      //          print("On Receive firing for existing claims")
      //          self.viewModel.fetchDataFromSalesforce()
      //        }
    }
    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    .edgesIgnoringSafeArea(.all)

  }
}

struct ExistingClaimsListView_Previews: PreviewProvider {
  static var previews: some View {
    let preview = ExistingClaimsListView()
    preview.viewModel.claims.records = Claim.generateDemoClaims(numberOfClaims: 5)
    return preview
  }
}
