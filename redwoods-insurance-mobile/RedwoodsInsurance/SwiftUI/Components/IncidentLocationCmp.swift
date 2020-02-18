//
//  IncidentLocationCmp.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/14/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct IncidentLocationCmp: View {
  @Binding var geoCodedAddressText: String
  @Binding var mapView: MKMapView

  var body: some View {
    VStack(alignment: .leading) {
      Text("Incident Location").font(.headline).padding(.leading)
      Text(geoCodedAddressText).padding(.leading).scaledToFit()
      ZStack {
        MapView(geoCodedAddressText: $geoCodedAddressText, mapView: $mapView)
        Image("BlueCar")
      }.frame(width: nil, height: 250.0, alignment: .center)
      Text("Move map to center car on incident location")
        .padding(.horizontal)
    }
  }
}

struct IncidentLocationCmp_Previews: PreviewProvider {
  static var previews: some View {
    IncidentLocationCmp(geoCodedAddressText: .constant("882 New Castle Ct"), mapView: .constant(MKMapView()))
  }
}
