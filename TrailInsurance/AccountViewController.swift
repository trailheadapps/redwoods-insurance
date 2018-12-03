//
//  AccountViewController.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit

class AccountViewController: UITableViewController,  SFDataSourceDelegate {
	func dataUpdated() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	let dataSource = SFDataSource<SFRecord>(withQuery: "SELECT Id, Name FROM Account", identifier: "acct", limit: false){
		SFRecord, cell in
		cell.textLabel?.text = (SFRecord["Name"] as! String)
		cell.detailTextLabel?.text = (SFRecord["Id"] as! String)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.dataSource.sfDataSourceDelegate = self
		self.tableView.dataSource = self.dataSource
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "acct")
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print(dataSource.sfRecords[indexPath.row])
		
		let mapView = IncidentLocationController(nibName: "IncidentMap", bundle:nil)
		self.navigationController?.pushViewController(mapView, animated: true)
	}
	
}
