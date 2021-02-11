//
//  NewClaimViewModel.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 10/29/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit
import Combine
import ContactsUI
import CoreLocation
import SalesforceSDKCore

class NewClaimViewModel: NSObject, ObservableObject {
  @Published var showActivityIndicator: Bool = false
  @Published var geoCodedAddressText: String = ""
  @Published var currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(), latitudinalMeters: 50, longitudinalMeters: 50)
  @Published var currentLocation = CLLocation()
  @Published var currentPlacemark: CLPlacemark?
  @Published var incidentDescription: String = ""
  @Published var audioRecording: Data?
  @Published var selectedImages = [UIImage]()
  @Published var selectedContacts = [CNContact]()
  @Published private var accountId = ""

  var cancellables = Set<AnyCancellable>()
  private let locationManager = CLLocationManager()
  private let geocoder = CLGeocoder()
  private let compositeRequestBuilder = CompositeRequestBuilder().setAllOrNone(false)
  private var users: RestClient.QueryResponse<User> = RestClient.QueryResponse<User>.getInstance(records: [User]())
  override init() {
    super.init()

    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.pausesLocationUpdatesAutomatically = false
      if let currentLocation = locationManager.location {
        self.currentRegion = generateRegion(location: currentLocation)
      }
    }

    self.$currentRegion
      .receive(on: RunLoop.main)
      .sink { newRegion in
        self.currentLocation = CLLocation(latitude: newRegion.center.latitude, longitude: newRegion.center.longitude)
      }
      .store(in: &cancellables)

    self.$currentLocation
      .receive(on: RunLoop.main)
      .sink { newLocation in
        self.geocoder.reverseGeocodeLocation(newLocation) { placemarks, _ in
          guard let placemark = placemarks?.first else {return}
          self.currentPlacemark = placemark
          self.geoCodedAddressText = placemark.toFormattedString()
        }
      }
      .store(in: &cancellables)

  }

}

extension NewClaimViewModel: CLLocationManagerDelegate {

  //Delegate Methods
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    locationManager.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      self.currentRegion = generateRegion(location: location)
    }
  }

  //Private methods. Used to DRY code.
  private func generateRegion(location: CLLocation) -> MKCoordinateRegion {
    let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    return MKCoordinateRegion(center: center, latitudinalMeters: 150, longitudinalMeters: 150)
  }

}

extension NewClaimViewModel {

  //Salesforce uploading methods
  func uploadClaimToSalesforce() -> Future<Bool, Never> {
    return Future { promise in
    self.showActivityIndicator = true
    Future<Bool, Error> { promise in
      self.createCase(promise)
    }
    .flatMap { _ in
      Future<Bool, Error> { promise in
        self.createContactRequests(promise)
      }
    }
    .flatMap {_ in
      Future<Bool, Error> { promise in
        self.createImageAttachments(promise)
      }
    }
    .flatMap {_ in
      Future<Bool, Error> { promise in
        self.createAudioAttachment(promise)
      }
    }
    .map {_ in
      self.generateMapSnapshot()
        .map({$0})
        .replaceError(with: UIImage())
        .sink(receiveValue: {mapImage in
          self.compositeRequestBuilder.add(RestClient.shared.requestForCreatingImageAttachment(
            from: mapImage,
            relatingToCaseID: "@{refCase.id}",
            fileName: "MapSnapshot.png"
          ), referenceId: "mapSnapshot")

        })
    }.map {_ in
      let compositeRequest = self.compositeRequestBuilder.buildCompositeRequest(RestClient.apiVersion)
      RestClient.shared.publisher(for: compositeRequest)
        .receive(on: RunLoop.main)
        .replaceError(with: CompositeResponse())
        .sink { value in
          print(value.subResponses)
          self.showActivityIndicator = false
          promise(.success(true))
        }.store(in: &self.cancellables)
    }
    .sink(receiveCompletion: { _ in}, receiveValue: {_ in})
    .store(in: &self.cancellables)
    }
  }

  func fetchAccountId(_ promise: @escaping (Result<Bool, Error>) -> Void) {
    let userId = UserAccountManager.shared.currentUserAccount!.accountIdentity.userId
    let accountIdQuery = RestClient.shared.request(forQuery: "SELECT contact.accountId FROM User WHERE ID = '\(userId)' LIMIT 1",
      apiVersion: RestClient.apiVersion)
    RestClient.shared.publisher(for: accountIdQuery)
      .print("debugging accountId pipeline")
      .tryMap { try $0.asJson() as? RestClient.JSONKeyValuePairs ?? [:]}
      .map { $0["records"] as? RestClient.SalesforceRecords ?? []}
      .map {$0[0]}
      .map { $0["Contact"] as! RestClient.SalesforceRecord}
      .map { $0["AccountId"] as! String}
      .replaceError(with: "")
      .assign(to: \.accountId, on: self)
      .store(in: &cancellables)

    promise(.success(true))
  }

  func createCase(_ promise: @escaping (Result<Bool, Error>) -> Void) {
    // Create Case
    let record = Case(
      subject: "Incident at \(self.geoCodedAddressText)",
      description: self.incidentDescription.isEmpty ? self.incidentDescription : "No Description Provided",
      Incident_Location_Txt__c: self.geoCodedAddressText.isEmpty ? self.geoCodedAddressText : "No address provided",
      Incident_Location__latitude__s: self.currentRegion.center.latitude,
      Incident_Location__longitude__s: self.currentRegion.center.longitude)

    self.compositeRequestBuilder.add(
      RestClient.shared.requestForCreate(withObjectType: "Case", fields: record.asSalesforceRecord, apiVersion: RestClient.apiVersion),
      referenceId: "refCase")
    promise(.success(true))
  }

  func createContactRequests(_ promise: @escaping (Result<Bool, Error>) -> Void ) {
    for(index, contact) in self.selectedContacts.enumerated() {
      let contactRec = Contact(contact: contact, index: index)
      let contactRequest = RestClient.shared.requestForCreate(withObjectType: "Contact", fields: contactRec.asSalesforceRecord, apiVersion: RestClient.apiVersion)
      self.compositeRequestBuilder.add(contactRequest, referenceId: "contact\(index)")
      let caseContactRequest = RestClient.shared.requestForCreate(withObjectType: "CaseContact__c", fields: contactRec.associationRecord, apiVersion: RestClient.apiVersion)
      self.compositeRequestBuilder.add(caseContactRequest, referenceId: "caseContact\(index)")
    }
    promise(.success(true))
  }

  func createImageAttachments(_ promise: @escaping (Result<Bool, Error>) -> Void ) {
    for(index, image) in self.selectedImages.enumerated() {
      let imgAttachmentRequest = RestClient.shared.requestForCreatingImageAttachment(from: image, relatingToCaseID: "@{refCase.id}")
      self.compositeRequestBuilder.add(imgAttachmentRequest, referenceId: "imageAttachment\(index)")
    }
    promise(.success(true))
  }

  func createAudioAttachment(_ promise: @escaping (Result<Bool, Error>) -> Void) {
    if let audioData = self.audioRecording {
    let audioAttachmentRequest = RestClient.shared.requestForCreatingAudioAttachment(from: audioData, relatingToCaseID: "@{refCase.id}")
    self.compositeRequestBuilder.add(audioAttachmentRequest, referenceId: "audioAttachment")
    }
    promise(.success(true))
  }

  func generateMapSnapshot() -> Future<UIImage, Error> {
    let options = MKMapSnapshotter.Options()
    options.region = self.currentRegion
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

        var point = snapshot.point(for: self.currentLocation.coordinate)
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

  private func handleError(_ error: Error?, urlResponse: URLResponse? = nil) {
    let errorDescription: String
    if let error = error {
      errorDescription = "\(error)"
    } else {
      errorDescription = "An unknown error occurred."
    }

    print(errorDescription)
  }

}
