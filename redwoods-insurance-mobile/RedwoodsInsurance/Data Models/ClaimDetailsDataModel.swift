//
//  ClaimDetailsModel.swift
//  Redwoods
//
//  Created by Kevin Poorman on 10/22/20.
//  Copyright © 2020 RedwoodsOrganizationName. All rights reserved.
//

import Foundation

struct ClaimDetailsDataModel: Identifiable, Hashable, Decodable {
  var id: UUID
  var key: String
  var value: String

  static func fromJson(record: [String: Any]) -> ClaimDetailsDataModel {
    return .init(
      id: UUID(),
      key: record.keys.first!,
      value: record.values.first as! String
    )
  }
}
