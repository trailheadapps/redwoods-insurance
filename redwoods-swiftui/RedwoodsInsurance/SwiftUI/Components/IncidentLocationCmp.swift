//
//  IncidentLocationCmp.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/14/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI

struct IncidentLocationCmp: View {
  @State var geoCodedAddressText: String = "Start"
  
  var body: some View {
    VStack{
      Text("Incident Location").font(.headline)
      Text(geoCodedAddressText).scaledToFit()
      ZStack {
        MapView(geoCodedAddressText: $geoCodedAddressText)
        Image("BlueCar")
      }.frame(width: nil, height: 250.0, alignment: .center)
      Text("Move map to center car on incident location")
    }
  }
}

struct IncidentLocationCmp_Previews: PreviewProvider {
  static var previews: some View {
    IncidentLocationCmp()
  }
}
