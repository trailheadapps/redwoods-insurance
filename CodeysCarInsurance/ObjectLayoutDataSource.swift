//
//  ObjectLayoutDataSource.swift
//  Codey's Car Insurance Project
//
//  Created by Kevin Poorman on 11/9/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import SalesforceSDKCore

/// Protocol adopted by classes that wish to be informed when an `ObjectLayoutDataSource`
/// instance is updated.
protocol ObjectLayoutDataSourceDelegate: AnyObject {

	/// Called when a data source has updated the value of its `fields` property.
	///
	/// - Parameter dataSource: The data source that was updated.
	func objectLayoutDataSourceDidUpdateFields(_ dataSource: ObjectLayoutDataSource)
}

/// Supplies data to a `UITableView` for a list of fields belonging to a single object.
/// An instance of this class can be used as a table view's `dataSource`.
class ObjectLayoutDataSource: NSObject {

	/// An individual field for an object retrieved from the Salesforce server.
	typealias ObjectField = (label: String, value: String)

	/// A closure that configures a given table view cell using the given
	/// label and value for a field of the requested object.
	typealias CellConfigurator = (ObjectField, UITableViewCell) -> Void

	/// The type of object to request from the server.
	let objectType: String

	/// The unique identifier of the object to request from the server.
	let objectId: String

	/// The reuse identifier to use for dequeueing cells from the table view.
	let cellReuseIdentifier: String

	/// The closure to call for each cell being provided by the data source.
	/// This will be called for each field in the object as it is displayed.
	let cellConfigurator: CellConfigurator

	/// The list of field names to omit from the results.
	let fieldBlacklist = ["attributes", "Id"]

	/// The fields for the object returned from the Salesforce server.
	/// Each field is a tuple providing the `label` and `value` for the field.
	private(set) var fields: [ObjectField] = []

	/// The delegate to notify when the list of fields is updated.
	weak var delegate: ObjectLayoutDataSourceDelegate?

	/// Initializes a data source for a given object type and identifier.
	///
	/// - Parameters:
	///   - objectType: The type of object to request from the server.
	///   - objectId: The unique identifier of the object to request from the server.
	///   - cellReuseIdentifier: The reuse identifier to use for dequeueing cells
	///     from the table view.
	///   - cellConfigurator: The closure to call for each cell being provided
	///     by the data source.
	init(objectType: String, objectId: String, cellReuseIdentifier: String, cellConfigurator: @escaping CellConfigurator) {
		self.objectType = objectType
		self.objectId = objectId
		self.cellReuseIdentifier = cellReuseIdentifier
		self.cellConfigurator = cellConfigurator
		super.init()
	}

	/// Logs the given error.
	///
	/// Codey's Car Insurance doesn't do any sophisticated error checking, and simply
	/// uses this as the failure handler for `RestClient` requests. In a real-world
	/// application, be sure to replace this with information presented to the user
	/// that can be acted on.
	///
	/// - Parameters:
	///   - error: The error to be logged.
	///   - urlResponse: Ignored; this argument provides compatibility with
	///     the `SFRestFailBlock` API.
	private func handleError(_ error: Error?, urlResponse: URLResponse? = nil) {
		let errorDescription: String
		if let error = error {
			errorDescription = "\(error)"
		} else {
			errorDescription = "An unknown error occurred."
		}
		SalesforceLogger.e(type(of: self), message: "Failed to successfully complete the REST request. \(errorDescription)")
	}

	/// Retrieves the compact layout metadata for the given object type, and
	/// based on the field list, constructs a request to retrieve the fields
	/// for the object with the given ID.
	///
	/// - Parameters:
	///   - objectType: The type of object to request from the server.
	///   - objectId: The unique identifier of the object to request from the server.
	///   - completionHandler: The closure to call when the request completes.
	///   - request: The request that was built, which can be used to retrieve
	///     the fields for the object.
	private func buildRequestFromCompactLayout(forObjectType objectType: String, objectId: String, completionHandler: @escaping (_ request: RestRequest) -> Void) {
		let layoutRequest = RestRequest(method: .GET, path: "/v44.0/compactLayouts?q=\(objectType)", queryParams: nil)
		layoutRequest.parseResponse = false
		RestClient.shared.send(request: layoutRequest, onFailure: handleError) { response, _ in
			guard let responseData = response as? Data else { return }
			do {
				// The root object of the compact layouts response is a dictionary
				// that maps object type names to their layouts. The first step
				// is to find the requested object type in the dictionary.
				let decodedJSON = try JSONDecoder().decode([String: CompactLayout].self, from: responseData)
				guard let layout = decodedJSON[objectType] else {
					SalesforceLogger.e(type(of: self), message: "Missing \(objectType) object type in response.")
					return
				}

				// The layout contains a list of fields (`fieldItems`), each of which
				// has an array of layout components, where the `value` of the layout
				// component is the field name.
				let fields = layout.fieldItems.compactMap { $0.layoutComponents.first?.value }
				let fieldList = fields.joined(separator: ", ")

				// Now a request can be built for the list of fields.
				let dataRequest = RestClient.shared.requestForRetrieve(withObjectType: objectType, objectId: objectId, fieldList: fieldList)
				completionHandler(dataRequest)
			} catch {
				self.handleError(error)
			}
		}
	}

	/// Sends the given request and parses the result into the `fields` list.
	///
	/// - Parameter request: The request to send.
	private func retrieveData(for request: RestRequest) {
		RestClient.shared.send(request: request, onFailure: handleError) { [weak self] response, _ in
			guard let self = self else { return }
			var resultsToReturn = [ObjectField]()
			if let dictionaryResponse = response as? [String: Any] {
				resultsToReturn = self.fields(from: dictionaryResponse)
			}
			DispatchQueue.main.async {
				self.fields = resultsToReturn
				self.delegate?.objectLayoutDataSourceDidUpdateFields(self)
			}
		}
	}

	/// Transforms the fields in the record into `ObjectField` values, omitting
	/// any fields that are in the blacklist or that are not strings.
	///
	/// - Parameter record: The record to be transformed.
	/// - Returns: The list of object fields extracted from the record.
	private func fields(from record: [String: Any]) -> [ObjectField] {
		let filteredRecord = record.lazy.filter { key, value in !self.fieldBlacklist.contains(key) && value is String }
		return filteredRecord.map { key, value in (label: key, value: value as! String) }
	}

	/// Retrieves the compact layout for the `objectType` and then fetches the
	/// fields specified in the layout for the object identified by `objectId`.
	///
	/// When it successfully completes, the `fields` property is set, and the
	/// delegate is notified of the update.
	@objc func fetchData() {
		self.buildRequestFromCompactLayout(forObjectType: self.objectType, objectId: self.objectId) { request in
			self.retrieveData(for: request)
		}
	}
}

extension ObjectLayoutDataSource: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fields.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
		cellConfigurator(fields[indexPath.row], cell)
		return cell
	}
}
