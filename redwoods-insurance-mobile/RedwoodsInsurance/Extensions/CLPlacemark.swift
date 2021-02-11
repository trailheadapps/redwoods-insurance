//
//  CLPlacemark.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 10/30/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {
  func toFormattedString() -> String {
    let number = self.subThoroughfare ?? ""
    let street = self.thoroughfare ?? ""
    let city = self.locality ?? ""
    let state = self.administrativeArea ?? ""
    let zip = self.postalCode ?? ""
    let country = self.isoCountryCode ?? ""
    return number + " " + street + " " + city + " " + state + ". " + zip + " " + country
  }
}
