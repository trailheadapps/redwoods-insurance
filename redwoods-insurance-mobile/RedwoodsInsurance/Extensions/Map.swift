//
//  Map.swift
//  Redwoods
//
//  Created by Kevin Poorman on 10/23/20.
//  Copyright © 2020 RedwoodsOrganizationName. All rights reserved.
//

import SwiftUI
import MapKit

extension View {
  func mapStyle(_ mapType: MKMapType) -> some View {
    MKMapView.appearance().mapType = mapType
    return self
  }

  public func mapStyle(_ mapType: MKMapType, showScale: Bool = true, showTraffic: Bool = false) -> some View {
    let map = MKMapView.appearance()
    map.mapType = mapType
    map.showsScale = showScale
    map.showsTraffic = showTraffic
    return self
  }

  func addAnnotations(_ annotations: [MKAnnotation]) -> some View {
    MKMapView.appearance().addAnnotations(annotations)
    return self
  }

  func addOverlay(_ overlay: MKOverlay) -> some View {
    MKMapView.appearance().addOverlay(overlay)
    return self
  }
}
