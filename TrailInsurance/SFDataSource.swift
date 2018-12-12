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
		self.buildQueryFromCompactLayout(forObjectType: obj, objectId: id) { request in
			self.retrieveData(withRequest: request)
		}
		
	}

	// TrailInsurance doesn't do any sophisticated error checking. When an SDK request fails, we just log it.
    func handleError(_ error: Error?, urlResponse: URLResponse? = nil) {
        let errorDescription: String
        if let error = error {
            errorDescription = "\(error)"
        } else {
            errorDescription = "An unknown error occurred."
        }
        SalesforceLogger.e(type(of: self), message: "Failed to successfully complete the REST request. \(errorDescription)")
    }

	// Retrieves the compact layout of the given object, and constructs a soql query from the returned metadata
	func buildQueryFromCompactLayout(forObjectType objectType: String, objectId: String, completionHandler: @escaping (_ request: RestRequest) -> Void) {
		let layoutRequest = RestRequest(method: .GET, path: "/v44.0/compactLayouts?q=\(objectType)", queryParams: nil)
		layoutRequest.parseResponse = false
		RestClient.shared.send(request: layoutRequest, onFailure: handleError) { response, _ in
            guard let responseData = response as? Data else { return }
            do {
                let decodedJSON = try JSONDecoder().decode(CaseCompactLayout.self, from: responseData)
                let fields = decodedJSON.caseCompactLayoutCase.fieldItems.map { $0.layoutComponents.first!.value }
                let fieldList = fields.joined(separator: ", ")
                let dataRequest = RestClient.shared.requestForRetrieve(withObjectType: objectType, objectId: objectId, fieldList: fieldList)
                completionHandler(dataRequest)
            } catch {
                self.handleError(error)
            }
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
		RestClient.shared.send(request: request, onFailure: handleError) { [weak self] response, _ in
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
