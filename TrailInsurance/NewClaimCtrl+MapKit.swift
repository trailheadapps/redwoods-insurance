//
//  NewClaimCtrl+MapKit.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/29/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import MapKit

extension NewClaimCtrl {

	func initMapViewExtension() {
		//CoreLocation setup
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		
		if checkLocationAuthorizationStatus() == true, let userLocation = locationManager.location {
			centerMap(on: userLocation)
		}
		
		//mapView setup
		mapView.delegate = self
		mapView.mapType = .hybrid
		mapView.isZoomEnabled = true
		mapView.isScrollEnabled = true
	}
	
	func geocode(_ location: CLLocation) {
        // Only one reverse geocoding can be in progress at a time, hence we need
        // to cancel any existing ones if we are getting location updates.
		geoCoder.cancelGeocode()
		geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else { return }
            self.geoCodedAddress = placemark
            let number = placemark.subThoroughfare ?? ""
            let street = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let zip = placemark.postalCode ?? ""
            let country = placemark.isoCountryCode ?? ""
            let address = number + " " + street + " " + city + " " + state + ". " + zip + " " + country
            self.addressLabel.text = address
            self.geoCodedAddressText = address
		}
	}

    private func centerMap(on location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
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
}

extension NewClaimCtrl: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		geocode(location)
	}
}

extension NewClaimCtrl: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		currentLocation = locations.last
	}
}
