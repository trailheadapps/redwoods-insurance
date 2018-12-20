//
//  OpenClaimsTableViewController.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

class OpenClaimsTableViewController: UITableViewController {
	
	/// Used by the storyboard to unwind other scenes back
	/// to this view controller.
	///
	/// Fetches new data whenever a new claim is submitted.
	///
	/// - Parameter segue: The segue to unwind.
	@IBAction func unwindFromNewClaim(segue: UIStoryboardSegue) {
		let newClaimViewController = segue.source as! NewClaimViewController
		if newClaimViewController.wasSubmitted {
			dataSource.fetchData()
		}
	}

	private let dataSource = ObjectListDataSource(soqlQuery: "SELECT Id, Subject, CaseNumber FROM Case WHERE Status != 'Closed'", cellReuseIdentifier: "CasePrototype") { record, cell in
		let subject = record["Subject"] as? String ?? ""
		let caseNumber = record["CaseNumber"] as? String ?? ""
		cell.textLabel?.text = subject
		cell.detailTextLabel?.text = "Case #: \(caseNumber)"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.dataSource.delegate = self
		self.tableView.delegate = self
		self.tableView.activityIndicatorView.startAnimating()
		self.tableView.dataSource = self.dataSource
		self.refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self.dataSource, action: #selector(self.dataSource.fetchData), for: UIControlEvents.valueChanged)
		self.tableView.addSubview(refreshControl!)
		self.dataSource.fetchData()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ViewClaimDetails" {
			let destination = segue.destination as! ClaimDetailsTableViewController
			let cell = sender as! UITableViewCell
			let indexPath = self.tableView.indexPath(for: cell)!
			if let claimId = self.dataSource.records[indexPath.row]["Id"] as? String {
				destination.claimId = claimId
			}
		}
	}
}

extension OpenClaimsTableViewController: ObjectListDataSourceDelegate {
	func objectListDataSourceDidUpdateRecords(_ dataSource: ObjectListDataSource) {
		DispatchQueue.main.async {
			self.tableView.reloadData()
			self.refreshControl?.endRefreshing()
			self.tableView.activityIndicatorView.stopAnimating()
		}
	}
}
