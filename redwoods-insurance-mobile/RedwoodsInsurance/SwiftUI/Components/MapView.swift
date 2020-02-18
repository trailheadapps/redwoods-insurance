//
//  MapView.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 1/13/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
  @EnvironmentObject var newClaim: NewClaimModel

  @Binding var geoCodedAddressText: String
  @Binding var mapView: MKMapView

  func makeUIView(context: Context) -> MKMapView {
    mapView.delegate = context.coordinator
    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {

  }

  func makeCoordinator() -> MapView.Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    let locationManager = CLLocationManager()
    var mkMapView: MKMapView!
    let regionRadius = 150.0
    let geoCoder = CLGeocoder()
    var geoCodedAddress: CLPlacemark?

    init(_ parent: MapView) {
      self.parent = parent
      self.mkMapView = self.parent.mapView
      super.init()

      locationManager.desiredAccuracy = kCLLocationAccuracyBest

      if checkLocationAuthorizationStatus() == true, let userLocation = locationManager.location {
        centerMap(on: userLocation)
      }

      mkMapView.mapType = .standard
      mkMapView.isZoomEnabled = true
      mkMapView.isScrollEnabled = true
      mkMapView.clipsToBounds = true
      mkMapView.layer.cornerRadius = 6
    }

    func checkLocationAuthorizationStatus() -> Bool? {
      if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
        locationManager.startUpdatingLocation()
        return true
      } else {
        locationManager.requestWhenInUseAuthorization()
        return nil
      }
    }

    private func centerMap(on location: CLLocation) {
      let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate,
                                                     latitudinalMeters: regionRadius,
                                                     longitudinalMeters: regionRadius)
      self.mkMapView?.setRegion(coordinateRegion, animated: true)
      geocode(location)
    }

    func geocode(_ location: CLLocation) {
      // Only one reverse geocoding can be in progress at a time, hence we need
      // to cancel any existing ones if we are getting location updates.
      geoCoder.cancelGeocode()
      geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
        guard let placemark = placemarks?.first else { return }
        self.geoCodedAddress = placemark
        let number = placemark.subThoroughfare ?? ""
        let street = placemark.thoroughfare ?? ""
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        // swiftlint:disable:next identifier_name
        let zip = placemark.postalCode ?? ""
        let country = placemark.isoCountryCode ?? ""
        let address = number + " " + street + " " + city + " " + state + ". " + zip + " " + country
        self.parent.geoCodedAddressText = address
        self.parent.newClaim.geolocationText = address
      }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
      geocode(location)
    }
  }
  
}
