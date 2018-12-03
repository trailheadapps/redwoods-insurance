//
//  NewClaimCtrl+MapKit.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/29/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import MapKit

extension NewClaimCtrl: MKMapViewDelegate, CLLocationManagerDelegate {
	
	func initMapViewExt() {
		//CoreLocation setup
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		
		if let _ = checkLocationAuthorizationStatus(), let userLocation = locationManager.location {
			centerMapOnCurrentLocation(location: userLocation)
		}
		
		//mapView setup
		mapView.delegate = self
		mapView.mapType = .hybrid
		mapView.isZoomEnabled = true
		mapView.isScrollEnabled = true
		
	}
	
	func geoCode(location : CLLocation!){
		/* Only one reverse geocoding can be in progress at a time hence we need to cancel existing
		one if we are getting location updates */
		geoCoder.cancelGeocode()
		geoCoder.reverseGeocodeLocation(location, completionHandler: { (data, error) -> Void in
			guard let placeMarks = data else {
				return
			}
			if let loc = placeMarks.first {
				self.geoCodedAddress = loc
				let number = loc.subThoroughfare ?? ""
				let street = loc.thoroughfare ?? ""
				let city = loc.locality ?? ""
				let state = loc.administrativeArea ?? ""
				let zip = loc.postalCode ?? ""
				let country = loc.isoCountryCode ?? ""
				let address = number + " " + street + " " + city + " " + state + ". " + zip + " " + country
				self.addressLabel.text = address
				self.geoCodedAddressText = address
			}
		})
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		self.geoCode(location: location)
	}
	
	private func centerMapOnCurrentLocation(location:CLLocation){
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
	
	// LocationManager Delegate Methods
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let locationValue:CLLocationCoordinate2D = manager.location!.coordinate
		defer { currentLocation = locations.last }
	}
	
}
