//
//  NewClaimCtrl+SFTransaction.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 12/2/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension NewClaimCtrl {
	
	func UploadClaimTransaction() {
		print("Starting transaction")
		let alert = UIAlertController(title: nil, message: "Submitting Claim", preferredStyle: .alert)
		let loadingModal = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50))
		loadingModal.hidesWhenStopped = true
		loadingModal.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
		loadingModal.startAnimating()
		alert.view.addSubview(loadingModal)
		present(alert, animated: true, completion: nil)
		sfUtils.getMasterAccountForUser(completion: createCase)
	}
	
	func createCase(_ masterAccountId:String) -> Void {
		print("Completed fetching the Master account Id: \(masterAccountId), starting to create case")
		var record: Dictionary<String, Any> = Dictionary<String,Any>()
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = DateFormatter.Style.full
		record["origin"] = "TrailInsurance Mobile App"
		record["status"] = "new"
		record["accountId"] = masterAccountId
		record["subject"] = "Incident on \(dateFormatter.string(from: Date()))"
		record["Description"] = self.transcribedText
		record["type"] = "Car Insurance"
		record["Reason"] = "Vehicle Incident"
		record["Incident_Location_Txt__c"] = self.geoCodedAddressText
		record["Incident_Location__latitude__s"] = self.mapView.centerCoordinate.latitude
		record["Incident_Location__longitude__s"] = self.mapView.centerCoordinate.longitude
		record["PotentialLiability__c"] = true

		sfUtils.createCase(from: record, completion: createContacts)
	}
	
	func createContacts(_ caseId:String) -> Void {
		print("Completed creating case. caseId: \(caseId). Uploading Contacts.")
		let createContactsRequest = sfUtils.createContactRequest(from: self.contactListData.contacts, accountId: masterAccountId)
		self.caseId = caseId
		sfUtils.sendCompositRequest(request: createContactsRequest, completion: createCaseContacts)
	}
	
	func createCaseContacts(_ contactIds:[String]) -> Void {
		print("Completed creating contacts. Creating case<->contact junction object records.")
		let caseContactCreateRequest = sfUtils.createCaseContactsCompositeRequest(caseId: self.caseId, contactIds: contactIds)
		sfUtils.sendCompositRequest(request: caseContactCreateRequest, completion: uploadMapImg)
	}
	
	func uploadMapImg(_ caseContactIds:[String]) -> Void {
		// in this case, we just discared the caseContactIds, as we don't need them.
		print("Completed creating case contact records, optionally uploading map image as attachment")
		guard let location = locationManager.location else {
			self.uploadPhotos("")
			return
		}
		let options = MKMapSnapshotOptions()
		let region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
		options.region = region
		options.scale = UIScreen.main.scale
		options.size = CGSize.init(width: 400, height: 400)
		options.mapType = .hybrid
		
		let snapShotter = MKMapSnapshotter(options: options)
		snapShotter.start() { image, error in
			guard let snapShot = image, error == nil else {
				return
			}
			UIGraphicsBeginImageContextWithOptions(options.size, true, 0)
			snapShot.image.draw(at: .zero)
			
			let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
			let pinImage = pinView.image
			
			var point = snapShot.point(for: location.coordinate)
			let pinCenterOffset = pinView.centerOffset
			point.x -= pinView.bounds.size.width / 2
			point.y -= pinView.bounds.size.height / 2
			point.x += pinCenterOffset.x
			point.y += pinCenterOffset.y
			pinImage?.draw(at: point)
			
			guard let mapImg = UIGraphicsGetImageFromCurrentImageContext(),
				let request = self.sfUtils.createImageFileUploadRequest(from: mapImg,
																															caseId: self.caseId) else {
																														self.uploadPhotos("")
																														return
			}
			self.sfUtils.sendRequestAndGetSingleProperty(with: request, completion: self.uploadPhotos)
			UIGraphicsEndImageContext()
		}
	}
	
	func uploadPhotos(_ mapId:String) -> Void {
		print("Completed uploading map image. Now uploading photos")
		let uploadRequests = sfUtils.createFileUploadRequests(from: self.selectedImages, accountId: self.masterAccountId, caseId: self.caseId)
		sfUtils.sendCompositRequest(request: uploadRequests, completion: uploadAudio)
		
	}
	
	func uploadAudio(_ :[String]) -> Void {
		print("Completed upload of photos. Uploading AudioFile")
		if let audioData = audioFileAsData(){
			let uploadRequest = sfUtils.createAudioFileUploadRequest(from: audioData, caseId: self.caseId)
			sfUtils.sendRequestAndGetSingleProperty(with: uploadRequest, completion: showConfirmation)
		}
	}
	
	func showConfirmation(_ mapIds:String) -> Void {
		print("Completed uploading audio file. Transaction complete!")
		dismiss(animated: true, completion: nil)
		DispatchQueue.main.async {
			self.tabBarController?.selectedIndex = 0
		}
	}
	
}
