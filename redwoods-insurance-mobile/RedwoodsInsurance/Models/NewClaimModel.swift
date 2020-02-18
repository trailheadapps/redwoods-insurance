//
//  NewClaimModel.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SalesforceSDKCore
import SwiftUI
import Combine
import ContactsUI
import MapKit

class NewClaimModel: ObservableObject {
  
  let newClaim = PassthroughSubject<NewClaimModel, Never>()
  let uploader = ClaimUpload()
  let userId = UserAccountManager.shared.currentUserAccount!.accountIdentity.userId
  
  public var images: [UIImage] = [UIImage]()
  public var contacts: [CNContact] = [CNContact]()
  private let compositeRequestBuilder = CompositeRequestBuilder().setAllOrNone(false)
  public var mapView: MKMapView = MKMapView()
  
  @Published var accountId = "" {
    didSet {
      newClaim.send(self)
    }
  }
  
  private var accountIdCancellable: AnyCancellable?
  private var compositeCancellable: AnyCancellable?
  
  func fetchAccountId() -> AnyPublisher<String,Never> {
    let accountIdQuery = RestClient.shared.request(forQuery: "SELECT contact.accountId FROM User WHERE ID = '\(userId)' LIMIT 1", apiVersion: RestClient.apiVersion)
    return RestClient.shared.publisher(for: accountIdQuery)
      .print("AccountID Query")
      .tryMap{ try $0.asJson() as? RestClient.JSONKeyValuePairs ?? [:] }
      .map{ $0["records"] as? RestClient.SalesforceRecords ?? [] }
      .mapError { dump($0) }
      .replaceError(with: [])
      .receive(on: RunLoop.main)
      .map{records in
        let accountRecord = records.first!
        let contact = accountRecord["Contact"] as! RestClient.SalesforceRecord
        let accountId = contact["AccountId"] as! String
        return accountId
      }.eraseToAnyPublisher()
    
  }
  
  func uploadClaimToSalesforce(map: MKMapView){
    self.mapView = map
    accountIdCancellable = fetchAccountId()
      .receive(on: RunLoop.main)
      .map({$0})
      .sink{ accountId in
        print("Uploading to Salesforce: fetched accountId: ", accountId)
        // Add create case request to composite request
        self.compositeRequestBuilder.add(self.createCase(), referenceId: "refCase")
        self.createContactRequests()
        self.createMapAttachment()
        self.createImageAttachments()
        
        let compositeRequest = self.compositeRequestBuilder.buildCompositeRequest(RestClient.apiVersion)
        print(compositeRequest.allSubRequests)
        print(compositeRequest.allOrNone)
      }
  }
  
  func createCase() -> RestRequest {
    // Create Case
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    
    var record = RestClient.SalesforceRecord()
    record["origin"] = "Redwoods Car Insurance Mobile App"
    record["status"] = "new"
    record["subject"] = "Incident on \(dateFormatter.string(from: Date()))"
    record["description"] = "Testing 123 - should be transcribed text"
    record["type"] = "Car Insurance"
    record["Reason"] = "Vehicle Incident"
    record["Incident_Location_Txt__c"] = "Testing 123 - should be geolocation text"
    record["Incident_Location__latitude__s"] = self.mapView.centerCoordinate.latitude
    record["Incident_Location__longitude__s"] = self.mapView.centerCoordinate.longitude
    record["PotentialLiability__c"] = true
    return RestClient.shared.requestForCreate(withObjectType: "Case", fields: record, apiVersion: RestClient.apiVersion)
  }
  
  func createContactRequests() {
    self.contacts.enumerated().forEach { (index, contact) -> Void in
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
      
      compositeRequestBuilder.add(RestClient.shared.requestForCreate(withObjectType: "Contact", fields: contactFields, apiVersion: RestClient.apiVersion), referenceId: "contact\(index)")
      
      let associationFields: RestClient.SalesforceRecord = [
        "Case__c": "refCase",
        "Contact__c": "contact\(index)"
      ]
      
      // Create CaseContacts__c
      compositeRequestBuilder.add(RestClient.shared.requestForCreate(withObjectType: "CaseContact__c", fields: associationFields, apiVersion: RestClient.apiVersion), referenceId: "caseContact\(index)")
    }
  }
  
  func createMapAttachment() {
    let regionRadius = 150.0
    let options = MKMapSnapshotter.Options()
    let region = MKCoordinateRegion.init(
      center: mapView.centerCoordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius
    )
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
      UIGraphicsEndImageContext()
      
      self.compositeRequestBuilder.add(RestClient.shared.requestForCreatingImageAttachment(
        from: mapImage,
        relatingToCaseID: "refCase",
        fileName: "MapSnapshot.png"
      ), referenceId: "mapSnapshot")
    }
  }
  
  func createImageAttachments() {
    for(index, image) in self.images.enumerated() {
      self.compositeRequestBuilder.add(RestClient.shared.requestForCreatingImageAttachment(from: image, relatingToCaseID: "refCase"), referenceId: "imageAttachment\(index)")
    }
  }
  
  func createAudioAttachments() {
    
  }
}
