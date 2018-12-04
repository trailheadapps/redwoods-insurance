//
//  SFDataSource+apiWrappers.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/30/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import ContactsUI
import UIKit

class SFUtilities {
	typealias SFSinglePropertyReturnCompletionHandler = (_ data: String) -> Void
	typealias SFDictCompletionHandler = (_ data: SFDict) -> Void
	typealias SFArrayOfIdsCompletionHandler = (_ data: [String]) -> Void
	typealias SFDict = Dictionary<String,Any>
	
	var masterAccountId = ""
	
	// TrailInsurance doesn't do any sophisticated error checking. When an SDK request fails, we just log it.
	func standardErrorHandler(err:Any, urlResp:Any) {
		SalesforceLogger.d(type(of: self), message: "Failed to successfully complete the REST REquest. Error is: \(String(describing: err))")
	}
	
	func getMasterAccountForUser(completion: @escaping SFSinglePropertyReturnCompletionHandler) {
		if let userId = UserAccountManager.shared.currentUserAccount?.accountIdentity.userId {
			let accountRequest = RestClient.shared.request(forQuery: "SELECT ID FROM Account WHERE ownerId = '\(userId)' AND isMaster__c = true LIMIT 1")
			RestClient.shared.send(request: accountRequest, onFailure: standardErrorHandler) { (response, _) in
				if let dictFromResponse = response as? Dictionary<String, Any> {
					if let records = dictFromResponse["records"] as? [Dictionary<String,Any>] {
						if let record = records.first {
							completion(record["Id"] as! String)
						}
					}
				}
			}
		}
	}
	
	func createCase(from record:Dictionary<String, Any>, completion: @escaping SFSinglePropertyReturnCompletionHandler) {
		let createRequest = RestClient.shared.requestForCreate(withObjectType: "Case", fields: record)
		RestClient.shared.send(request: createRequest, onFailure: standardErrorHandler) { (response, _) in
			if let record = response as? Dictionary<String,Any> {
				completion(record["id"] as! String)
			}
		}
	}
	
	func createContactRequest(from records: [CNContact], accountId: String) -> RestRequest {
		var requests: [RestRequest] = [RestRequest]()
		var refIds: [String] = [String]()
		
		for (index,contact) in records.enumerated() {
			let address = contact.postalAddresses.first
			let sfDict: SFDict = [
				"LastName": contact.familyName,
				"FirstName": contact.givenName,
				"AccountId": accountId,
				"Phone": contact.phoneNumbers.first?.value.stringValue ?? "",
				"email": contact.emailAddresses.first?.value ?? "",
				"MailingStreet": address?.value.street ?? "",
				"MailingCity": address?.value.city ?? "",
				"MailingState": address?.value.state ?? "",
				"MailingPostalCode": address?.value.postalCode ?? "",
				"MailingCountry": address?.value.country ?? ""
			]
			let req = RestClient.shared.requestForCreate(withObjectType: "Contact", fields: sfDict)
			requests.append(req)
			
			refIds.append("RefId-\(index)")
		}
		
		return RestClient.shared.compositeRequest(requests, refIds: refIds, allOrNone: false)
	}
	
	func sendCompositRequest(request: RestRequest, completion: @escaping SFArrayOfIdsCompletionHandler){
		RestClient.shared.send(request: request, onFailure: standardErrorHandler) { (response, _) in
			//removed unneeded  [weak self]
			var ids: [String] = [String]()
			guard let jsonResponse = response as? SFDict,
				let results = jsonResponse["compositeResponse"] as? [SFDict] else {
				return
			}
			for respBody in results {
				if let body = respBody["body"] as? SFDict {
					ids.append(body["id"] as! String)
				}
			}
			completion(ids)
		}
	}
	
	func createImageFileUploadRequest(from image:UIImage, caseId: String) -> RestRequest? {
		guard let half = image.resizeImageByHalf(),
			let imageData = UIImageJPEGRepresentation(half, 0.75) else {
			return nil
		}
		let fileName = NSUUID().uuidString + ".jpg"
		return createGenericFileUploadRequestFor(file: imageData, caseId: caseId, filename: fileName)
	}
	
	func createAudioFileUploadRequest(from audioFile:Data, caseId: String) -> RestRequest {
		let fileName = NSUUID().uuidString + ".m4a"
		return createGenericFileUploadRequestFor(file: audioFile, caseId: caseId, filename: fileName)
	}
	
	func createGenericFileUploadRequestFor(file: Data, caseId: String, filename: String) -> RestRequest {
		let record: Dictionary<String,Any> = [
			"Name": filename,
			"Body": file.base64EncodedString(options: .lineLength64Characters),
			"parentId": caseId
		]
		
		return RestClient.shared.requestForCreate(withObjectType: "Attachment", fields: record)
	}
	
	func sendRequestAndGetSingleProperty(with request: RestRequest, completion: @escaping SFSinglePropertyReturnCompletionHandler) {
		RestClient.shared.send(request: request, onFailure: standardErrorHandler) { (response, _) in
				if let record = response as? Dictionary<String,Any> {
					completion(record["id"] as! String)
				}
			}
	}
	
	func createFileUploadRequests(from images:[UIImage], accountId: String, caseId: String) -> RestRequest {
		var requests: [RestRequest] = [RestRequest]()
		var refIds: [String] = [String]()
		
		for img in images {
			if let req = createImageFileUploadRequest(from: img, caseId: caseId){
				requests.append(req)
				refIds.append(NSUUID().uuidString)
			}
		}
		return RestClient.shared.compositeRequest(requests, refIds: refIds, allOrNone: false)
	}
	
	func createCaseContactsCompositeRequest(caseId:String, contactIds:[String]) -> RestRequest {
		var requests: [RestRequest] = [RestRequest]()
		var refIds: [String] = [String]()

		for contact in contactIds {
			let sfDict: SFDict = [
				"CaseId__c": caseId,
				"ContactId__c": contact
			]
			let req = RestClient.shared.requestForCreate(withObjectType: "CaseContact__c", fields: sfDict)
			refIds.append(contact)
			requests.append(req)
		}
		return RestClient.shared.compositeRequest(requests, refIds: refIds, allOrNone: false)

	}
	
	
}
