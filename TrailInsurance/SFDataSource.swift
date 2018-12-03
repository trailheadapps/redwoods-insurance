//
//  SFDataSource.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

typealias SFRecord = Dictionary<String, Any>

class SFDataSource<SFRecord>: NSObject, UITableViewDataSource {
	typealias CellConfigurator = (SFRecord, UITableViewCell) -> Void
	typealias StringCompletionBlock = (_ result: String) -> Void
	private let reusableIdentifier:String
	private let cellConfigurator:CellConfigurator
	var sfRecords = [SFRecord]()
	var sfQueryString:String
	var limitToLoggedInUser = false
	weak var sfDataSourceDelegate: SFDataSourceDelegate?
	let fieldBlacklist = ["attributes", "Id"]
	
	init(withQuery query:String, identifier reusable:String, limit:Bool, cellConfigurator: @escaping CellConfigurator){
		self.sfQueryString = query
		self.limitToLoggedInUser = limit
		self.reusableIdentifier = reusable
		self.cellConfigurator = cellConfigurator
		super.init()
		fetchData()
	}
	
	init(for obj: String, id: String, identifier reusable:String, cellConfigurator: @escaping CellConfigurator) {
		self.sfQueryString = ""
		self.limitToLoggedInUser = false
		self.reusableIdentifier = reusable
		self.cellConfigurator = cellConfigurator
		super.init()
		self.buildQueryFromCompactLayout(for: obj, id: id) { (response) in
			self.sfQueryString = response
			self.fetchData()
		}
		
	}

	func buildQueryFromCompactLayout(for obj: String, id: String, completion: @escaping StringCompletionBlock) {
		let layoutReq = RestRequest.init(method: .GET, path: "/v44.0/compactLayouts?q=\(obj)", queryParams:nil)
		layoutReq.parseResponse = false
		RestClient.shared.send(request: layoutReq, onFailure: { (_,_) in
			SalesforceLogger.d(type(of: self), message: "Error Inoking describe query with: \(layoutReq)")
		}) { (response, _) in //removed [weak self] before (rfesponse, _)
			if let respData = response as? Data{
				if let jsonObj = try? JSONDecoder().decode(CaseCompactLayout.self, from: respData){
					let fields = jsonObj.caseCompactLayoutCase.fieldItems.map({ (fieldItem) -> String in return (fieldItem.layoutComponents.first?.value)!})
					let query = "SELECT Id, " + fields.joined(separator: ", ") + " FROM \(obj) WHERE id = '\(id)'"
					completion(query)
				}
			}
		}
	}
	
	func limitQueryByLoggedInUserID(query:String) -> String {
		var q = query
		if let userId = UserAccountManager.shared.currentUserAccountIdentity?.userId {
			q += "'\(userId)'"
		}
		return q
	}
	
	// Protocol Methods
	func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
		return sfRecords.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier, for: indexPath)
		let obj = sfRecords[indexPath.row]
		cellConfigurator(obj, cell)
		return cell
	}
	
	@objc func fetchData() {
		if(limitToLoggedInUser){
			self.sfQueryString = limitQueryByLoggedInUserID(query: sfQueryString)
		}
		let SFApiRequest = RestClient.shared.request(forQuery: sfQueryString)
		RestClient.shared.send(request: SFApiRequest, onFailure: { (_,_) in
			SalesforceLogger.d(type(of:self), message: "Error Invoking SFRestAPI request with request: \(SFApiRequest)")
		}) { [weak self] (response, _) in
//			[weak self] (response, urlResponse) in
//
//			guard let strongSelf = self,
//				let jsonResponse = response as? Dictionary<String,Any>,
//				let result = jsonResponse ["records"] as? [Dictionary<String,Any>]  else {
//					return
//			}
			if let dictionaryResp = response as? Dictionary<String, Any> {
				if let results = dictionaryResp["records"] as? [SFRecord] {
					var resultsToReturn = [SFRecord]()
					if dictionaryResp["totalSize"] as! Int == 1 {
						// a single record should return a dictionary of fields -> value
						resultsToReturn = (self?.fields(from: results[0]))!
				
					} else {
						resultsToReturn = results
					}
					
					DispatchQueue.main.async {
						self?.sfRecords = resultsToReturn
						self?.sfDataSourceDelegate?.dataUpdated()
					}
				}
			}
		}
	}

}
