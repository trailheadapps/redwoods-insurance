//
//  ObjectLayoutDataSource.swift
//  Redwoods Insurance Project
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
	typealias SFRecord = [String: Any]

	/// A closure that configures a given table view cell using the given
	/// label and value for a field of the requested object.
	typealias CellConfigurator = ([String: Any], UITableViewCell) -> Void

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
	private(set) var fields: [SFRecord] = []

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
	/// Redwoods Insurance doesn't do any sophisticated error checking, and simply
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

	/// Retrieves the compact layout for the `objectType` and then fetches the
	/// fields specified in the layout for the object identified by `objectId`.
	///
	/// When it successfully completes, the `fields` property is set, and the
	/// delegate is notified of the update.
	@objc func fetchData() {
		guard !self.objectId.isEmpty else { return }
		let queryParams: [String: Any] = ["layoutTypes": "Compact"]
		let layoutRequest = RestRequest(method: .GET, path: "/\(RestClient.APIVERSION)/ui-api/record-ui/\(self.objectId)",
			queryParams: queryParams)

		RestClient.shared.send(request: layoutRequest, onFailure: handleError) { [weak self] response, _ in
			guard
				let self = self,
				let dictionaryResponse = response as? [String: Any],
				let records = dictionaryResponse["records"] as? [String: Any],
				let firstRecord = records[self.objectId] as? [String: Any],
				let fields = firstRecord["fields"] as? [String: Any] else { return }

			var resultsToReturn = [SFRecord]()
			// swiftlint:disable:next identifier_name
			for (key, value) in fields {
				if let displayValue = value as? [String: Any] {
					if let finalValue = displayValue["displayValue"] as? String {
						resultsToReturn.append([key: finalValue])
					} else if let finalValue = displayValue["value"] as? String {
						resultsToReturn.append([key: finalValue])
					} else {
						resultsToReturn.append([key: " "])
					}

				}
			}

			DispatchQueue.main.async {
				self.fields = resultsToReturn
				self.delegate?.objectLayoutDataSourceDidUpdateFields(self)
			}
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
