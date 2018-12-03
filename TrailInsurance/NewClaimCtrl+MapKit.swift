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
				print(address)
			}
			
		})
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
		self.geoCode(location: location)
		self.mapSnapshot = getSnapshotMap(location: location)
	}
	
	private func getSnapshotMap(location: CLLocation) -> UIImage {
		let options = MKMapSnapshotOptions()
		let region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
		options.region = region
		options.scale = UIScreen.main.scale
		options.size = CGSize.init(width: 400, height: 400)
		options.mapType = .standard
		var mapSnapshot = UIImage()

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
			
			if let img = UIGraphicsGetImageFromCurrentImageContext() {
				mapSnapshot = img
			}
			UIGraphicsEndImageContext()
			
		}
		return mapSnapshot
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
