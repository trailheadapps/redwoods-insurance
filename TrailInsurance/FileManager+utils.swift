//
//  AppDelegate+utils.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/29/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation

extension FileManager {
	class func getDocumentsDir() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDir = paths[0]
		return documentsDir
	}
}
