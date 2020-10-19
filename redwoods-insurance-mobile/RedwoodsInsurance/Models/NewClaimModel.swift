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
  
  @Published var geolocationText: String?
  @Published var images: [UIImage] = [UIImage]()
  @Published var selectedContacts = [CNContact]()
  @Published var showActivityIndicator: Bool = false
  @Published var transcribedText: String?
  
  let completedPublisher = PassthroughSubject<Bool, Never>()
  
  var audioData: Data?
  private var compositeRequestBuilder = CompositeRequestBuilder().setAllOrNone(false)
  @Published var mapView: MKMapView = MKMapView()
  
  @Published var accountId = "" {
    didSet {
      newClaim.send(self)
    }
  }
  
  private var accountIdCancellable: AnyCancellable?
  private var mapSnapshotCancellable: AnyCancellable?
  private var compositeCancellable: AnyCancellable?
  private var uploadCancellable: AnyCancellable?
  
  func fetchAccountId() -> AnyPublisher<String, Never> {
    let userId = UserAccountManager.shared.currentUserAccount!.accountIdentity.userId
    let accountIdQuery = RestClient.shared.request(forQuery: "SELECT contact.accountId FROM User WHERE ID = '\(userId)' LIMIT 1",
      apiVersion: RestClient.apiVersion)
    return RestClient.shared.publisher(for: accountIdQuery)
      .tryMap { try $0.asJson() as? RestClient.JSONKeyValuePairs ?? [:] }
      .map { $0["records"] as? RestClient.SalesforceRecords ?? [] }
      .mapError { dump($0) }
      .replaceError(with: [])
      .receive(on: RunLoop.main)
      .map {records in
        let accountRecord = records.first!
        let contact = accountRecord["Contact"] as! RestClient.SalesforceRecord // swiftlint:disable:this force_cast
        let accountId = contact["AccountId"] as! String // swiftlint:disable:this force_cast
        return accountId
    }.eraseToAnyPublisher()
    
  }
  
  func uploadClaimToSalesforce(map: MKMapView) -> Future<Bool, Never> {
    compositeRequestBuilder = CompositeRequestBuilder().setAllOrNone(true)
    self.mapView = map
    return Future { promise in
      self.accountIdCancellable = self.fetchAccountId()
        .receive(on: RunLoop.main)
        .map({$0})
        .sink { accountId in
          print("Uploading to Salesforce: fetched accountId: ", accountId)
          // Add create case request to composite request
          self.compositeRequestBuilder.add(self.createCase(), referenceId: "refCase")
          self.createContactRequests()
          self.createImageAttachments()
          self.createAudioAttachments()
          self.mapSnapshotCancellable = self.generateMapSnapshot()
            .map({$0})
            .replaceError(with: UIImage())
            .sink(receiveValue: { mapImage in
              self.compositeRequestBuilder.add(RestClient.shared.requestForCreatingImageAttachment(
                from: mapImage,
                relatingToCaseID: "@{refCase.id}",
                fileName: "MapSnapshot.png"
              ), referenceId: "mapSnapshot")
              
              let compositeRequest = self.compositeRequestBuilder.buildCompositeRequest(RestClient.apiVersion)
              self.uploadCancellable = RestClient.shared.publisher(for: compositeRequest)
                .receive(on: RunLoop.main)
                .replaceError(with: CompositeResponse())
                .sink { value in
                  print(value)
                  self.showActivityIndicator = false
                  self.completedPublisher.send(true)
                  promise(.success(true))
              }
            })
      }
    }
    
  }
  
  private func handleError(_ error: Error?, urlResponse: URLResponse? = nil) {
    let errorDescription: String
    if let error = error {
      errorDescription = "\(error)"
    } else {
      errorDescription = "An unknown error occurred."
    }
    
    print(errorDescription)
  }
  
  func createCase() -> RestRequest {
    // Create Case
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    
    var record = RestClient.SalesforceRecord()
    record["origin"] = "Redwoods Car Insurance Mobile App"
    record["status"] = "new"
    record["subject"] = "Incident on \(dateFormatter.string(from: Date()))"
    record["description"] = self.transcribedText ?? "No description provided"
    record["type"] = "Car Insurance"
    record["Reason"] = "Vehicle Incident"
    record["Incident_Location_Txt__c"] = self.geolocationText ?? "No address provided"
    record["Incident_Location__latitude__s"] = self.mapView.centerCoordinate.latitude
    record["Incident_Location__longitude__s"] = self.mapView.centerCoordinate.longitude
    record["PotentialLiability__c"] = true
    return RestClient.shared.requestForCreate(withObjectType: "Case", fields: record, apiVersion: RestClient.apiVersion)
  }
  
  func createContactRequests() {
    self.selectedContacts.enumerated().forEach { (index, contact) -> Void in
      let address = contact.postalAddresses.first
      let contactFields: [String: String] = [
        "LastName": (contact.familyName.isEmpty) ? "No Last Name Given" : contact.familyName,
        "FirstName": contact.givenName,
        "Phone": contact.phoneNumbers.first?.value.stringValue ?? "",
        "email": (contact.emailAddresses.first?.value as String?) ?? "",
        "MailingStreet": address?.value.street ?? "",
        "MailingCity": address?.value.city ?? "",
        "MailingState": address?.value.state ?? "",
        "MailingPostalCode": address?.value.postalCode ?? "",
        "MailingCountry": address?.value.country ?? ""
      ]
      
      let contactRequest =  RestClient.shared.requestForCreate(withObjectType: "Contact",
                                                               fields: contactFields,
                                                               apiVersion: RestClient.apiVersion)
      compositeRequestBuilder.add(contactRequest, referenceId: "contact\(index)")
      
      let associationFields: RestClient.SalesforceRecord = [
        "Case__c": "@{refCase.id}",
        "Contact__c": "@{contact\(index).id}"
      ]
      
      // Create CaseContacts__c
      let caseContactRequest = RestClient.shared.requestForCreate(withObjectType: "CaseContact__c",
                                                                  fields: associationFields,
                                                                  apiVersion: RestClient.apiVersion)
      compositeRequestBuilder.add(caseContactRequest, referenceId: "caseContact\(index)")
    }
  }
  
  func generateMapSnapshot() -> Future<UIImage, Error> {
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
    
    let futureSnapshot = Future<UIImage, Error> { promise in
      snapshotter.start {snapshot, error in
        if let err = error {
          return promise(.failure(err))
        }
        
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
        return promise(.success(mapImage))
      }
    }
    return futureSnapshot
  }
  
  func createImageAttachments() {
    self.$images
      .sink { images in
        for(index, image) in images.enumerated() {
          let imageAttachmentRequest = RestClient.shared.requestForCreatingImageAttachment(from: image, relatingToCaseID: "@{refCase.id}")
          self.compositeRequestBuilder.add(imageAttachmentRequest, referenceId: "imageAttachment\(index)")
        }
    }.cancel()
  }
  
  func createAudioAttachments() {
    if let audioData = audioData {
      let audioAttachmentRequest = RestClient.shared.requestForCreatingAudioAttachment(from: audioData, relatingToCaseID: "@{refCase.id}")
      self.compositeRequestBuilder.add(audioAttachmentRequest, referenceId: "audioAttachment")
    }
  }
}

struct NewClaimModel_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
