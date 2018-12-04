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
	typealias CellConfigurator = (SFRecord?, UITableViewCell) -> Void
	typealias StringCompletionBlock = (_ result: String) -> Void
	typealias RequestCompletionBlock = (_ request: RestRequest) -> Void
	typealias SFResponseDictionary = Dictionary<String,Any>
	
	private let reusableIdentifier:String
	private let cellConfigurator:CellConfigurator
	private var forceMultiple = false
	let fieldBlacklist = ["attributes", "Id"]
	
	private var sfQueryString:String = ""
	
	var sfRecords: [SFRecord]?
	weak var sfDataSourceDelegate: SFDataSourceDelegate?

	// Initializer for making a query
	init(withQuery query:String, identifier reusable:String, cellConfigurator: @escaping CellConfigurator){
		self.sfQueryString = query
		self.reusableIdentifier = reusable
		self.cellConfigurator = cellConfigurator
		super.init()
		fetchData()
	}
	
	// Convience init for forcing a multiple record query, when the query may only return a single result
	convenience init(withQuery query:String, identifier reusable:String, forceMultiple:Bool, cellConfigurator: @escaping CellConfigurator){
		self.init(withQuery:query, identifier: reusable, cellConfigurator: cellConfigurator);
		self.forceMultiple = true
	}

	// Initializer for querying the compact layout of the specified object.
	init(for obj: String, id: String, identifier reusable:String, cellConfigurator: @escaping CellConfigurator) {
		self.sfQueryString = ""
		self.reusableIdentifier = reusable
		self.cellConfigurator = cellConfigurator
		super.init()
		self.buildQueryFromCompactLayout(for: obj, id: id) { (request) in
			self.retrieveData(withRequest: request)
		}
		
	}

	// TrailInsurance doesn't do any sophisticated error checking. When an SDK request fails, we just log it.
	func standardErrorHandler(err:Any, urlResp:Any) {
		SalesforceLogger.d(type(of: self), message: "Failed to successfully complete the REST REquest. Error is: \(String(describing: err))")
	}
	
	// Retrieves the compact layout of the given object, and constructs a soql query from the returned metadata
	func buildQueryFromCompactLayout(for obj: String, id: String, completion: @escaping RequestCompletionBlock) {
		let layoutReq = RestRequest.init(method: .GET, path: "/v44.0/compactLayouts?q=\(obj)", queryParams:nil)
		//			let query = RestClient.requestForLayout()

		layoutReq.parseResponse = false
		RestClient.shared.send(request: layoutReq, onFailure: standardErrorHandler) { (response, _) in
			guard let responseData = response as? Data,
				let decodedJSON = try? JSONDecoder().decode(CaseCompactLayout.self, from: responseData) else {
					return
			}
			let fields = decodedJSON.caseCompactLayoutCase.fieldItems.map({ (fieldItem) -> String in return (fieldItem.layoutComponents.first?.value)!})
			let dataRequest = RestClient.shared.requestForRetrieve(withObjectType: obj, objectId: id, fieldList: fields.joined(separator: ", "))
			completion(dataRequest)
		}
	}
	
	// Protocol Methods
	func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
		return sfRecords?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier, for: indexPath)
		if let obj = sfRecords?[indexPath.row]{
			cellConfigurator(obj, cell)
		}
		return cell
	}
	
	@objc func fetchData() {
		let SFApiRequest = RestClient.shared.request(forQuery: sfQueryString)
		self.retrieveData(withRequest: SFApiRequest)
	}
	
	func retrieveData(withRequest request:RestRequest){
		RestClient.shared.send(request: request, onFailure: standardErrorHandler) { [weak self] (response, _) in
			guard let dictionaryResponse = response as? SFResponseDictionary else { return }

			var resultsToReturn = [SFRecord]()
			if let records = dictionaryResponse["records"] as? [SFRecord] {
				// we have a query result with multiple records
				resultsToReturn = records
			} else {
				// we have a retrieve result, with fields of a single record.
				resultsToReturn = (self?.fields(from: dictionaryResponse))!
			}
			
			DispatchQueue.main.async {
				self?.sfRecords = resultsToReturn
				self?.sfDataSourceDelegate?.dataUpdated()
			}
		}
	}

}
