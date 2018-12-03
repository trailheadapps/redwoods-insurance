//
//  newCase.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/30/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation

struct NewCase {
	let accountId: String
	let caseId: String
	let origin: String = "Web"
	let status: String = "New"
	let subject: String
	var dictionary: [String: Any] {
		return [
			"accountId": accountId,
			"origin" : origin,
			"status": status,
			"subject": subject
		]
	}
}
