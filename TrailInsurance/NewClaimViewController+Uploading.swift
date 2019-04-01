//
//  NewClaimViewController+Uploading.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 12/2/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import MapKit

import SalesforceSDKCore

// Extends `NewClaimViewController` with methods for submitting the claim details
// to the server.
//
// Each of these methods, starting with `uploadClaimTransaction()`, executes an
// asynchronous request, and in the completion handler for the request, calls
// the next method in the chain.
//
// The majority of the `RestClient` methods being called are from an extension
// in RestClient+TrailInsurance.swift.
extension NewClaimViewController {

	/// Logs the given error.
	///
	/// TrailInsurance doesn't do any sophisticated error checking, and simply
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

	/// Begins the process of uploading the claim details to the server.
	func uploadClaimTransaction() {
		SalesforceLogger.d(type(of: self), message: "Starting transaction")

		let alert = UIAlertController(title: nil, message: "Submitting Claim", preferredStyle: .alert)
		let loadingModal = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
		loadingModal.hidesWhenStopped = true
		loadingModal.style = .gray
		loadingModal.startAnimating()
		alert.view.addSubview(loadingModal)
		present(alert, animated: true, completion: nil)

		RestClient.shared.fetchMasterAccountForUser(onFailure: handleError) { masterAccountID in
			SalesforceLogger.d(type(of: self), message: "Completed fetching the Master account ID: \(masterAccountID). Starting to create case.")
			self.createCase(withAccountID: masterAccountID)
		}
	}

	/// Creates a new Case record from the transcribed text and map location.
	/// When complete, `createContacts(relatingToAccountID:forCaseID:)` is called.
	///
	/// - Parameter accountID: The ID of the account with which the case is
	///   to be associated.
	private func createCase(withAccountID accountID: String) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .full

		var record = [String: Any]()
		record["origin"] = "TrailInsurance Mobile App"
		record["status"] = "new"
		record["accountId"] = accountID
		record["subject"] = "Incident on \(dateFormatter.string(from: Date()))"
		record["description"] = self.transcribedText
		record["type"] = "Car Insurance"
		record["Reason"] = "Vehicle Incident"
		record["Incident_Location_Txt__c"] = self.geoCodedAddressText
		record["Incident_Location__latitude__s"] = self.mapView.centerCoordinate.latitude
		record["Incident_Location__longitude__s"] = self.mapView.centerCoordinate.longitude
		record["PotentialLiability__c"] = true

		RestClient.shared.createCase(withFields: record, onFailure: handleError) { newCaseID in
			SalesforceLogger.d(type(of: self), message: "Completed creating case with ID: \(newCaseID). Uploading Contacts.")
			self.createContacts(relatingToAccountID: accountID, forCaseID: newCaseID)
		}
	}

	/// Creates Contact records for each of the contacts that the user added.
	/// When complete, `createCaseContacts(withContactIDs:forCaseID:)` is called.
	///
	/// - Parameters:
	///   - accountID: The ID of the account with which the contact records are
	///     to be associated.
	///   - caseID: The ID of the case that is being modified.
	private func createContacts(relatingToAccountID accountID: String, forCaseID caseID: String) {
		let contactsRequest = RestClient.shared.compositeRequestForCreatingContacts(from: contacts, relatingToAccountID: accountID)
		RestClient.shared.sendCompositeRequest(contactsRequest, onFailure: handleError) { contactIDs in
			SalesforceLogger.d(type(of: self), message: "Completed creating \(self.contacts.count) contact(s). Creating case<->contact junction object records.")
			self.createCaseContacts(withContactIDs: contactIDs, forCaseID: caseID)
		}
	}

	/// Associates the given Contact record IDs with the case.
	/// When complete, `uploadMapImage(forCaseID:)` is called.
	///
	/// - Parameters:
	///   - contactIDs: The IDs of the Contact records being associated with the case.
	///   - caseID: The ID of the case that is being modified.
	private func createCaseContacts(withContactIDs contactIDs: [String], forCaseID caseID: String) {
		let associationRequest = RestClient.shared.compositeRequestForCreatingAssociations(fromContactIDs: contactIDs, toCaseID: caseID)
		RestClient.shared.sendCompositeRequest(associationRequest, onFailure: handleError) { _ in
			SalesforceLogger.d(type(of: self), message: "Completed creating \(contactIDs.count) case contact record(s). Optionally uploading map image as attachment.")
			self.uploadMapImage(forCaseID: caseID)
		}
	}

	/// Generates a snapshot image of the map view and uploads it as an attachment.
	/// When complete, `uploadPhotos(forCaseID:)` is called.
	///
	/// - Parameter caseID: The ID of the case that is being modified.
	private func uploadMapImage(forCaseID caseID: String) {
		let options = MKMapSnapshotter.Options()
		let region = MKCoordinateRegion.init(center: mapView.centerCoordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		options.region = region
		options.scale = UIScreen.main.scale
		options.size = CGSize(width: 800, height: 800)
		options.mapType = .standard

		let snapshotter = MKMapSnapshotter(options: options)
		snapshotter.start { snapshot, error in
			guard let snapshot = snapshot, error == nil else {
				return
			}
			UIGraphicsBeginImageContextWithOptions(options.size, true, 0)
			snapshot.image.draw(at: .zero)

			let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
			let pinImage = pinView.image

			var point = snapshot.point(for: self.mapView.centerCoordinate)
			let pinCenterOffset = pinView.centerOffset
			point.x -= pinView.bounds.size.width / 2
			point.y -= pinView.bounds.size.height / 2
			point.x += pinCenterOffset.x
			point.y += pinCenterOffset.y
			pinImage?.draw(at: point)

			let mapImage = UIGraphicsGetImageFromCurrentImageContext()!
			let attachmentRequest = RestClient.shared.requestForCreatingImageAttachment(from: mapImage, relatingToCaseID: caseID)

			UIGraphicsEndImageContext()
		
			RestClient.shared.send(request: attachmentRequest, onFailure: self.handleError) { _, _ in
				SalesforceLogger.d(type(of: self), message: "Completed uploading map image. Now uploading photos.")
				self.uploadPhotos(forCaseID: caseID)
			}
		}
	}

	/// Uploads each photo as an attachment.
	/// When complete, `uploadAudio(forCaseID:)` is called.
	///
	/// - Parameter caseID: The ID of the case that is being modified.
	private func uploadPhotos(forCaseID caseID: String) {
		for (index, img) in self.selectedImages.enumerated() {
			let attachmentRequest = RestClient.shared.requestForCreatingImageAttachment(from: img, relatingToCaseID: caseID)
			RestClient.shared.send(request: attachmentRequest, onFailure: self.handleError){ result, _ in
				SalesforceLogger.d(type(of: self), message: "Completed upload of photo \(index + 1) of \(self.selectedImages.count).")
			}
		}
		self.uploadAudio(forCaseID: caseID)
	}

	/// Uploads the recorded audio as an attachment.
	/// When complete, `showConfirmation()` is called.
	///
	/// - Parameter caseID: The ID of the case that is being modified.
	private func uploadAudio(forCaseID caseID: String) {
		if let audioData = audioFileAsData() {
			let attachmentRequest = RestClient.shared.requestForCreatingAudioAttachment(from: audioData, relatingToCaseID: caseID)
			RestClient.shared.send(request: attachmentRequest, onFailure: handleError) { _, _ in
				SalesforceLogger.d(type(of: self), message: "Completed uploading audio file. Transaction complete!")
				self.unwindToClaims()
			}
		} else {
			// Complete upload if there is no audio file.
			SalesforceLogger.d(type(of: self), message: "No audio file to upload. Transaction complete!")
			self.unwindToClaims()
		}
	}

	/// Dismisses the current modal and returns the user to open claims.
	private func unwindToClaims() {
		wasSubmitted = true
		// Unwind back to claims. UI calls must be performed on the main thread.
		DispatchQueue.main.async {
			self.performSegue(withIdentifier: "unwindFromNewClaim", sender: self)
		}
	}
}
