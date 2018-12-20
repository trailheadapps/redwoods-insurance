//
//  NewClaimCtrl.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/28/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import ContactsUI

class NewClaimViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var recordingTimerLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var transcriptionText: UITextView!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var photoCollectionView: UICollectionView!
	@IBOutlet weak var contactList: UITableView!

	let locationManager = CLLocationManager()
	let regionRadius = 150.0
	let geoCoder = CLGeocoder()
	let contactPicker = CNContactPickerViewController()
	let contactListData = ContactListDataSource()

	var recordingSession: AVAudioSession!
	var incidentRecorder: AVAudioRecorder!
	var audioPlayer: AVAudioPlayer!
	var meterTimer: Timer!
	var currentLocation: CLLocation?
	var geoCodedAddress: CLPlacemark?
	var geoCodedAddressText: String = ""
	var transcribedText: String = ""
	var isPlaying = false
	var imagePickerCtrl: UIImagePickerController!
	var selectedImages: [UIImage] = []
	var mapSnapshot: UIImage?
	
	var wasSubmitted = false

	override func viewDidLoad() {
		super.viewDidLoad()
		//Setup Mapview
		initMapViewExtension()
		//Recording Setup
		initAVRecordingExtension()
		//Setup Camera, and Image access
		initImageExtension()

		// setup our Contact List data source
		contactList.dataSource = contactListData
		// put a border arround the contact list.
		contactList.layer.borderColor = UIColor.black.cgColor
		contactList.layer.borderWidth = 1
	}

	@IBAction func submitClaim(_ sender: Any) {
		uploadClaimTransaction()
	}
}
