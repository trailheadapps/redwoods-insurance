//
//  MKCoordinateRegion.swift
//  Redwoods
//
//  Created by Kevin Poorman on 10/28/20.
//  Copyright © 2020 RedwoodsOrganizationName. All rights reserved.
//

import Foundation
import MapKit

extension MKCoordinateRegion: Equatable {
  public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
    if lhs.center.latitude != rhs.center.latitude || lhs.center.longitude != rhs.center.longitude {
      return false
    }
    if lhs.span.latitudeDelta != rhs.span.latitudeDelta || lhs.span.longitudeDelta != rhs.span.longitudeDelta {
      return false
    }
    return true
  }
}
