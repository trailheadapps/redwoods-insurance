//
//  AccountViewController.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

class ExistingClaimsCtrl: UITableViewController,  SFDataSourceDelegate {
	
	
	func dataUpdated() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
			self.refreshControl?.endRefreshing()
			self.tableView.activityIndicatorView.stopAnimating()
		}
	}
	
	let dataSource = SFDataSource<SFRecord>(withQuery: "SELECT Id, Subject, CaseNumber FROM Case WHERE Status != 'Closed'", identifier: "CasePrototype", forceMultiple: true){
		SFRecord, cell in
		if let record = SFRecord {
			cell.textLabel?.text = (SFRecord?["Subject"] as! String)
			cell.detailTextLabel?.text = "Case #: " + (SFRecord?["CaseNumber"] as! String)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.dataSource.sfDataSourceDelegate = self
		self.tableView.delegate = self
		self.tableView.activityIndicatorView.startAnimating()
		self.tableView.dataSource = self.dataSource
		self.refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self.dataSource, action: #selector(self.dataSource.fetchData), for: UIControlEvents.valueChanged)
		self.tableView.addSubview(refreshControl!)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ViewClaimDetails"{
			if let destination = segue.destination as? ClaimViewCtrl {
				if let cell = sender as? UITableViewCell,
					let indexPath = self.tableView.indexPath(for: cell) {
					let claimId = self.dataSource.sfRecords?[indexPath.row]["Id"] as! String
					destination.claimId = claimId
				}
			}
		}
	}
}
