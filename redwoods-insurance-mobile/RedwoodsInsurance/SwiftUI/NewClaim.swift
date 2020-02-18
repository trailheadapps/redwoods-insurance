//
//  NewClaim.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/9/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import SwiftUI
import ContactsUI
import Combine
import SalesforceSDKCore
import MapKit

struct NewClaim: View {
  @EnvironmentObject var newClaim: NewClaimModel

  @State var geoCodedAddressText: String = "Start"
  @State var mapView: MKMapView = MKMapView()
  @State var uploadComplete: AnyCancellable?

  @Environment(\.presentationMode) var mode: Binding<PresentationMode>

  var body: some View {
    ActivityIndicatorView(isShowing: self.$newClaim.showActivityIndicator) {
      ScrollView {
        VStack {
          IncidentLocationCmp(geoCodedAddressText: self.$geoCodedAddressText, mapView: self.$mapView)
          DescriptionCmp()
            .frame(height: 200.0)
          PhotosCmp(selectedImages: self.newClaim.images)
            .frame(height: 200.0)
          PartiesInvolvedCmp()
            .frame(height: 200.0)
            .navigationBarItems(
              trailing: Button("Submit") {
                self.newClaim.showActivityIndicator = true
                print("Submitting")
                self.uploadComplete = self.newClaim.uploadClaimToSalesforce(map: self.mapView)
                  .sink { _ in
                    self.mode.wrappedValue.dismiss()
                }
              }
          )
        }

      }
    }
  }
}

struct NewClaim_Previews: PreviewProvider {
  static let env = NewClaimModel()
  static var previews: some View {
    NewClaim().environmentObject(env)
  }
}
