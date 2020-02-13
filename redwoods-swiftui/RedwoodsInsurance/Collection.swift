//
//  Collection.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/24/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation

extension Collection {

  func get(at index: Index) -> Iterator.Element? {
    return self.indices.contains(index) ? self[index] : nil
  }
}
