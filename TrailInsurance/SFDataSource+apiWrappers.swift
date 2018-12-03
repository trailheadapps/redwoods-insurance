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
	
	func getMasterAccountForUser(completion: @escaping SFSinglePropertyReturnCompletionHandler) {
		if let userId = UserAccountManager.shared.currentUserAccount?.accountIdentity.userId {
			let accountRequest = RestClient.shared.request(forQuery: "SELECT ID FROM Account WHERE ownerId = '\(userId)' AND isMaster__c = true LIMIT 1")
			RestClient.shared.send(request: accountRequest, onFailure: {(_,_) in
				SalesforceLogger.d(type(of: self), message: "Error Invoking Rest API with request: \(accountRequest)")
			}) { (response, _) in
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
		RestClient.shared.send(request: createRequest, onFailure: {(_,_) in
			SalesforceLogger.d(type(of: self), message: "Failed to create object using request: \( createRequest)")
		}) { (response, _) in
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
		RestClient.shared.send(request: request, onFailure: { (error, urlResp) in
			SalesforceLogger.d(type(of: self), message: "failed to execute Rest api request. Request is: \(request) and Error is: \(String(describing: error)) and urlResp is: \(String(describing: urlResp))")
		}) { [weak self] (response, urlResp) in
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
	
	func createImageFileUploadRequest(from image:UIImage, accountId: String, caseId: String) -> RestRequest? {
		guard let imageData = UIImagePNGRepresentation(image) else {
			return nil
		}
		let record: Dictionary<String,Any> = [
			"Name": NSUUID().uuidString + ".png",
			"Body": imageData.base64EncodedString(options: .lineLength64Characters),
			"parentId": caseId
		]
		
		return RestClient.shared.requestForCreate(withObjectType: "Attachment", fields: record)
	}
	
	func createAudioFileUploadRequest(from audioFile:Data, accountId: String, caseId: String) -> RestRequest {
		let record: Dictionary<String,Any> = [
			"Name": NSUUID().uuidString + ".m4a",
			"Body": audioFile.base64EncodedString(options: .lineLength64Characters),
			"parentId": caseId
		]
		
		return RestClient.shared.requestForCreate(withObjectType: "Attachment", fields: record)
	}
	
	func sendRequestAndGetSingleProperty(with request: RestRequest, completion: @escaping SFSinglePropertyReturnCompletionHandler) {
		RestClient.shared.send(request: request, onFailure: { (error, urlResp) in
				SalesforceLogger.d(type(of: self), message: "failed to execute Rest api request. Request is: \(request) and Error is: \(String(describing: error)) and urlResp is: \(String(describing: urlResp))")
			}) { (response, urlResp) in
				if let record = response as? Dictionary<String,Any> {
					completion(record["id"] as! String)
				}
			}
	}
	
	func createFileUploadRequests(from images:[UIImage], accountId: String, caseId: String) -> RestRequest { //actually a composite request
		var requests: [RestRequest] = [RestRequest]()
		var refIds: [String] = [String]()
		
		for img in images {
			if let req = createImageFileUploadRequest(from: img, accountId: accountId, caseId: caseId){
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
