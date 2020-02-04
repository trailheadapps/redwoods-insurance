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
  
  var body: some View {
    VStack{
      IncidentLocationCmp(geoCodedAddressText: $geoCodedAddressText, mapView: $mapView)
      DescriptionCmp()
      PhotosCmp(selectedImages: newClaim.images)
      PartiesInvolvedCmp()
    }
    .navigationBarItems(
      trailing: Button("Submit"){
        print("Submitting")
        self.newClaim.uploadClaimToSalesforce(map: self.mapView)
      }
    )
  }
  
  
  
}

struct NewClaim_Previews: PreviewProvider {
    static var previews: some View {
        NewClaim()
    }
}
