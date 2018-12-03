//
//  NewClaimCtrl+SFTransaction.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 12/2/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation

extension NewClaimCtrl {
	
	func UploadClaimTransaction() {
		print("Starting transaction")
		sfUtils.getMasterAccountForUser(completion: createCase)
	}
	
	func createCase(_ masterAccountId:String) -> Void {
		print("Completed fetching the Master account Id: \(masterAccountId), starting to create case")
		var record: Dictionary<String, Any> = Dictionary<String,Any>()
		record["origin"] = "web"
		record["status"] = "new"
		record["accountId"] = masterAccountId
		record["subject"] = "Test Case create"
		record["description"] = self.transcribedText

		sfUtils.createCase(from: record, completion: createContacts)
	}
	
	func createContacts(_ caseId:String) -> Void {
		print("Completed creating case. caseId: \(caseId). Uploading Contacts.")
		let createContactsRequest = sfUtils.createContactRequest(from: contacts, accountId: masterAccountId)
		self.caseId = caseId
		sfUtils.sendCompositRequest(request: createContactsRequest, completion: createCaseContacts)
	}
	
	func createCaseContacts(_ contactIds:[String]) -> Void {
		print("Completed creating contacts. Creating case<->contact junction object records.")
		let caseContactCreateRequest = sfUtils.createCaseContactsCompositeRequest(caseId: self.caseId, contactIds: contactIds)
		sfUtils.sendCompositRequest(request: caseContactCreateRequest, completion: uploadMapImg)
	}
	
	func uploadMapImg(_ caseContactIds:[String]) -> Void {
		print("Completed creating case contact records, optionally uploading map image as attachment")
		// in this case, we just discared the caseContactIds, as we don't need them.
		guard let mapImg = mapSnapshot,
			let request = sfUtils.createImageFileUploadRequest(from: mapImg,
																												 accountId: self.masterAccountId, caseId: self.caseId) else {
			self.uploadPhotos("")
			return
		}
		sfUtils.sendRequestAndGetSingleProperty(with: request, completion: uploadPhotos)
	}
	
	func uploadPhotos(_ mapId:String) -> Void {
		print("Completed uploading map image. Now uploading photos")
		let uploadRequests = sfUtils.createFileUploadRequests(from: self.selectedImages, accountId: self.masterAccountId, caseId: self.caseId)
		sfUtils.sendCompositRequest(request: uploadRequests, completion: uploadAudio)
		
	}
	
	func uploadAudio(_ :[String]) -> Void {
		print("Completed upload of photos. Uploading AudioFile")
		if let audioData = audioFileAsData(){
			let uploadRequest = sfUtils.createAudioFileUploadRequest(from: audioData , accountId: self.masterAccountId, caseId: self.caseId)
			sfUtils.sendRequestAndGetSingleProperty(with: uploadRequest, completion: showConfirmation)
		}
		
	}
	
	func showConfirmation(_ mapIds:String) -> Void {
		print("Completed uploading audio file. Transaction complete!")
	}
	
}
