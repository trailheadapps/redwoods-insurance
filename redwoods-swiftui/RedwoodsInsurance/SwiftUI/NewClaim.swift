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
  @State var geoCodedAddressText: String = "Start"
  @State var mapView: MKMapView = MKMapView()
  @EnvironmentObject var newClaim: NewClaimModel
  @Environment(\.presentationMode) var mode: Binding<PresentationMode>
  
  var body: some View {
    ActivityIndicatorView(isShowing: self.$newClaim.showActivityIndicator) {
      VStack{
        IncidentLocationCmp(geoCodedAddressText: self.$geoCodedAddressText, mapView: self.$mapView)
        DescriptionCmp()
        PhotosCmp(selectedImages: self.newClaim.images)
        PartiesInvolvedCmp()
        .navigationBarItems(
          trailing: Button("Submit"){
            self.newClaim.showActivityIndicator = true
            print("Submitting")
            self.newClaim.uploadClaimToSalesforce(map: self.mapView)
            self.mode.wrappedValue.dismiss()
          }
        )
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
