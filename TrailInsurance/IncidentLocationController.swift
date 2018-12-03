//
//  IncidentLocationController.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/12/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class IncidentLocationController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	
	@IBOutlet weak var mapView: MKMapView!
	
	private var currentLocation: CLLocation?
	let locationManager = CLLocationManager()
	var dragPin: MKPointAnnotation!
	let regionRadius: CLLocationDistance = 1000
	
	
	func centerMapOnLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
																															regionRadius, regionRadius)
		mapView.setRegion(coordinateRegion, animated: true)
	}
	
	func checkLocationAuthorizationStatus() {
		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			mapView.showsUserLocation = true
			locationManager.startUpdatingLocation()
		} else {
			locationManager.requestWhenInUseAuthorization()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		
		mapView.mapType = .standard
		mapView.isZoomEnabled = true
		mapView.isScrollEnabled = true
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
		gestureRecognizer.numberOfTouchesRequired = 1
		
		mapView.addGestureRecognizer(gestureRecognizer)
		
		let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
		centerMapOnLocation(location: initialLocation)
		checkLocationAuthorizationStatus()
		if let coor = mapView.userLocation.location?.coordinate{
			mapView.setCenter(coor, animated: true)
		}
	}

	@objc func addPin(gestureRecognizer:UIGestureRecognizer){
		let touchPoint = gestureRecognizer.location(in: mapView)
		let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
		if dragPin != nil {
			dragPin.coordinate = newCoordinates
		}
		
		if gestureRecognizer.state == UIGestureRecognizerState.began {
			dragPin = MKPointAnnotation()
			dragPin.coordinate = newCoordinates
			mapView.addAnnotation(dragPin)
		} else if gestureRecognizer.state == UIGestureRecognizerState.ended {
			dragPin = nil
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let locValue:CLLocationCoordinate2D = manager.location!.coordinate
		defer { currentLocation = locations.last }
		
		if currentLocation == nil {
			// Zoom to user location
			if let userLocation = locations.last {
				let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
				mapView.setRegion(viewRegion, animated: true)
			}
		}
		dragPin = MKPointAnnotation()
		dragPin.coordinate = locValue
		dragPin.title = "Incident Location"
		mapView.addAnnotation(dragPin)
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !(annotation is MKPointAnnotation) else {
			return nil
		}
		let reuseIdentifier = "IncidentLocation"
		var pinView: MKAnnotationView?
		if let deQueuedPinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) {
			pinView = deQueuedPinView
			pinView?.annotation = annotation
		} else {
			pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		}
		
		if let pinView = pinView {
			pinView.canShowCallout = true
			pinView.tintColor = .purple
			pinView.isDraggable = true
		}
		
		return nil
	}

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
		switch newState {
		case .starting:
			view.dragState = .dragging
		case .ending, .canceling:
			view.dragState = .none
		default:
			break
		}
	}
	
}
