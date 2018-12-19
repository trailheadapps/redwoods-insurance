//
//  ClaimViewCtrl.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/26/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore

class ClaimDetailsTableViewController: UITableViewController, SFDataSourceDelegate {

	var claimId: String?
	var dataSource: SFDataSource<SFRecord>?
	let reuseIdentifier = "CaseDetailPrototype"

	func dataUpdated() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
			self.tableView.activityIndicatorView.stopAnimating()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		if let caseId = claimId {
			self.dataSource = SFDataSource<SFRecord>(for: "Case", id: caseId, identifier: self.reuseIdentifier) {
				SFRecord, cell in
				cell.textLabel?.text = (SFRecord?["value"] as! String)
				cell.detailTextLabel?.text = (SFRecord?["label"] as! String)
			}
			self.dataSource?.sfDataSourceDelegate = self
			self.tableView.delegate = self
			self.tableView.activityIndicatorView.startAnimating()
			self.tableView.dataSource = dataSource
		}

	}
}
