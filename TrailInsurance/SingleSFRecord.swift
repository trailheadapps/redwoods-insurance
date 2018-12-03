//
//  SingleSFRecord.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/28/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation

extension SFDataSource {
	// a list of fields we never want to display to the user when viewing a single record

	func fields(from record: SFRecord) -> [SFRecord] {
		guard let data = record as? Dictionary<String,Any> else {
			fatalError("Record must be passed in!")
		}
		var fieldsArray = [SFRecord]()
		for (key,value) in data {
			if !fieldBlacklist.contains(key) {
				if let v = value as? String {
					fieldsArray.append([
						"label" : key,
						"value" : v
						] as! SFRecord)
				}
			}
		}
		return fieldsArray
	}
}
