//
//  RestClient+NewClaim.swift
//  Redwoods Insurance Project
//
//  Created by Kevin Poorman on 11/30/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import ContactsUI

import SalesforceSDKCore

// Extends SalesforceSDKCore.RestClient with convenience methods for working
// with `Case` records.
extension RestClient {
	static let APIVERSION = "v48.0" // what api version to use for rest calls

	/// An error that may occur while sending a request related to `Case` records.
	enum CaseRequestError: LocalizedError {

		/// The response dictionary did not contain the expected fields.
		case responseDataCorrupted(keyPath: String)

		/// A localized message describing what error occurred.
		var errorDescription: String? {
			switch self {
			case .responseDataCorrupted(let keyPath):
				return "The response dictionary did not contain the expected fields: \(keyPath)"
			}
		}
	}

	/// Sends a composite request for creating records and calls the completion
	/// handler with the list of resulting IDs.
	///
	/// - Parameters:
	///   - compositeRequest: The request to be sent.
	///   - failureHandler: The closure to call if the request fails
	///     (due to timeout, cancel, or error).
	///   - completionHandler: The closure to call if the request successfully
	///     completes.
	///   - ids: The list of IDs for the created records.
	func sendCompositeRequest(
		_ compositeRequest: RestRequest,
		onFailure failureHandler: @escaping RestFailBlock,
		completionHandler: @escaping (_ ids: [String]) -> Void) {
		self.send(request: compositeRequest, onFailure: failureHandler) { response, urlResponse in
			guard let responseDictionary = response as? [String: Any],
			      let results = responseDictionary["compositeResponse"] as? [[String: Any]]
			else {
				failureHandler(CaseRequestError.responseDataCorrupted(keyPath: "compositeResponse"), urlResponse)
				return
			}
			let resultIds = results.compactMap { result -> String? in
				guard let resultBody = result["body"] as? [String: Any] else { return nil }
				return resultBody["id"] as? String
			}
			completionHandler(resultIds)
		}
	}

	/// Fetches the ID for the first Account record belonging to the current user.
	///
	/// - Note: The user must be logged in before calling this method.
	///
	/// - Parameters:
	///   - failureHandler: The closure to call if the request fails
	///     (due to timeout, cancel, or error).
	///   - completionHandler: The closure to call if the request successfully
	///     completes.
	///   - accountID: The ID of the master account.
	func fetchMasterAccountForUser(
		onFailure failureHandler: @escaping RestFailBlock,
		completionHandler: @escaping (_ accountID: String) -> Void) {
		let userID = UserAccountManager.shared.currentUserAccount!.accountIdentity.userId
		let accountRequest = self.request(
			forQuery: "SELECT Contact.AccountID FROM User WHERE Id = '\(userID)' LIMIT 1",
			apiVersion: RestClient.APIVERSION
		)
		self.send(request: accountRequest, onFailure: failureHandler) { response, urlResponse in
			guard let responseDictionary = response as? [String: Any],
			      let records = responseDictionary["records"] as? [[String: Any]],
						let contact = records.first?["Contact"] as? [String: Any],
						let accountID = contact["AccountId"] as? String
			else {
				failureHandler(CaseRequestError.responseDataCorrupted(keyPath: "Contact.AccountId"), urlResponse)
				return
			}
			completionHandler(accountID)
		}
	}

	/// Creates a new Case record and calls the completion handler with the
	/// resulting ID.
	///
	/// - Parameters:
	///   - record: The initial field names and values for the record.
	///   - failureHandler: The closure to call if the request fails
	///     (due to timeout, cancel, or error).
	///   - completionHandler: The closure to call if the request successfully
	///     completes.
	///   - caseID: The ID of the created Case record.
	func createCase(
		withFields fields: [String: Any],
		onFailure failureHandler: @escaping RestFailBlock,
		completionHandler: @escaping (_ caseID: String) -> Void) {
		let createRequest = self.requestForCreate(withObjectType: "Case", fields: fields, apiVersion: RestClient.APIVERSION)
		self.send(request: createRequest, onFailure: failureHandler) { response, urlResponse in
			guard let record = response as? [String: Any],
			      let caseID = record["id"] as? String
			else {
				failureHandler(CaseRequestError.responseDataCorrupted(keyPath: "id"), urlResponse)
				return
			}
			completionHandler(caseID)
		}
	}

	/// Returns a request that executes multiple subrequests, with automatically
	/// generated RefIDs following the pattern "RefID-0", "RefID-1", and so on.
	///
	/// - Parameter requests: The list of subrequests to execute.
	/// - Returns: The new composite request.
	private func compositeRequestWithSequentialRefIDs(composedOf requests: [RestRequest]) -> RestRequest {
		let refIDs = (0..<requests.count).map { "RefID-\($0)" }
		return self.compositeRequest(requests, refIds: refIDs, allOrNone: false, apiVersion: RestClient.APIVERSION)
	}

	/// Returns a composite request that executes requests to create records
	/// for each of the given contacts.
	///
	/// - Parameters:
	///   - contacts: The contacts to create records for.
	///   - accountID: The ID of the account with to which the contact records
	///     should be related.
	/// - Returns: The new composite request.
	func compositeRequestForCreatingContacts(
		from contacts: [CNContact],
		relatingToAccountID accountID: String) -> RestRequest {
		let requests = contacts.map { contact -> RestRequest in
			let address = contact.postalAddresses.first
			let contactFields: [String: String] = [
				"LastName": contact.familyName,
				"FirstName": contact.givenName,
				"Phone": contact.phoneNumbers.first?.value.stringValue ?? "",
				"email": (contact.emailAddresses.first?.value as String?) ?? "",
				"MailingStreet": address?.value.street ?? "",
				"MailingCity": address?.value.city ?? "",
				"MailingState": address?.value.state ?? "",
				"MailingPostalCode": address?.value.postalCode ?? "",
				"MailingCountry": address?.value.country ?? ""
			]
			return self.requestForCreate(withObjectType: "Contact", fields: contactFields, apiVersion: RestClient.APIVERSION)
		}
		return self.compositeRequestWithSequentialRefIDs(composedOf: requests)
	}

	/// Returns a request that adds an image attachment to a given case.
	///
	/// - Parameters:
	///   - image: The image to be attached to the case.
	///   - caseID: The ID of the case to which the attachment is to be added.
	/// - Returns: The new request.
	func requestForCreatingImageAttachment(
		from image: UIImage,
		relatingToCaseID caseID: String,
		fileName: String? = nil) -> RestRequest {
		let imageData = image.resizedByHalf().pngData()!
		let uploadFileName = fileName ?? UUID().uuidString + ".png"
		return self.requestForCreatingAttachment(from: imageData, withFileName: uploadFileName, relatingToCaseID: caseID)
	}

	/// Returns a request that adds an audio attachment to a given case.
	///
	/// - Parameters:
	///   - m4aAudioData: The audio data, in M4A format, to be attached to the case.
	///   - caseID: The ID of the case to which the attachment is to be added.
	/// - Returns: The new request.
	func requestForCreatingAudioAttachment(from m4aAudioData: Data, relatingToCaseID caseID: String) -> RestRequest {
		let fileName = UUID().uuidString + ".m4a"
		return self.requestForCreatingAttachment(from: m4aAudioData, withFileName: fileName, relatingToCaseID: caseID)
	}

	/// Returns a request that adds an attachment to a given case.
	///
	/// - Parameters:
	///   - data: The data for the attachment.
	///   - fileName: The name to give the attachment (typically including
	///     a file extension).
	///   - caseID: The ID of the case to which the attachment is to be added.
	/// - Returns: The new request.
	private func requestForCreatingAttachment(
		from data: Data,
		withFileName fileName: String,
		relatingToCaseID caseID: String) -> RestRequest {
		let record = ["VersionData": data.base64EncodedString(options: .lineLength64Characters),
					  "Title": fileName, "PathOnClient": fileName, "FirstPublishLocationId": caseID]
		return self.requestForCreate(withObjectType: "ContentVersion", fields: record, apiVersion: RestClient.APIVERSION)
	}

	/// Returns a composite request that executes requests to associate each
	/// of the given Contact record IDs with a given case.
	///
	/// - Parameters:
	///   - contactIDs: The IDs of the contact records to be associated with
	///     the case.
	///   - caseID: The ID of the case with which the contacts are to be associated.
	/// - Returns: The new composite request.
	func compositeRequestForCreatingAssociations(
		fromContactIDs contactIDs: [String],
		toCaseID caseID: String) -> RestRequest {
		let requests = contactIDs.map { contactID -> RestRequest in
			let associationFields: [String: String] = [
				"Case__c": caseID,
				"Contact__c": contactID
			]
			return self.requestForCreate(withObjectType: "CaseContact__c", fields: associationFields, apiVersion: RestClient.APIVERSION)
		}
		return self.compositeRequest(requests, refIds: contactIDs, allOrNone: false, apiVersion: RestClient.APIVERSION)
	}
}
