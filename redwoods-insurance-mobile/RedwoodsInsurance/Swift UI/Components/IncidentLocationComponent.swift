//
//  IncidentLocationComponent.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 10/30/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//
import Foundation
import SwiftUI
import MapKit
import Combine

struct IncidentLocationComponent: View {
  @ObservedObject var newClaimViewModel: NewClaimViewModel

  var body: some View {
    VStack(alignment: .leading) {
      Text("Incident Location")
        .font(.headline)
        .padding(.leading)
      Text(self.$newClaimViewModel.geoCodedAddressText.wrappedValue)
        .padding(.leading)
        .scaledToFit()
      ZStack {
        Map(coordinateRegion: self.$newClaimViewModel.currentRegion)
          .onChange(of: self.$newClaimViewModel.currentRegion.wrappedValue) { _ in
            // no op call. we need this closure to fire the event
            {}()
          }
        Image("BlueCar")
      }.frame(width: nil, height: 250.0, alignment: .center)
      Text("Move map to center car on incident location")
        .padding(.horizontal)
    }
  }
}

struct IncidentLocationComponent_Previews: PreviewProvider {
  static var previews: some View {
    let newClaimViewModel = NewClaimViewModel()
    IncidentLocationComponent(newClaimViewModel: newClaimViewModel)
  }
}
