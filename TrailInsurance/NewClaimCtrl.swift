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

class NewClaimCtrl: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var recordingTimerLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var transcriptionText: UITextView!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var photoCollectionView: UICollectionView!
	
	
	let locationManager = CLLocationManager()
	let regionRadius = 150.0
	let geoCoder = CLGeocoder()
	let contactPicker = CNContactPickerViewController()
//	let contactStore = CNContactStore()
	
	var recordingSession: AVAudioSession!
	var incidentRecorder: AVAudioRecorder!
	var audioPlayer : AVAudioPlayer!
	var meterTimer: Timer!
	var currentLocation: CLLocation?
	var geoCodedAddress: CLPlacemark?
	var transcribedText: String = ""
	var isPlaying = false
	var imagePickerCtrl: UIImagePickerController!
	var selectedImages: [UIImage] = []
	var contacts: [CNContact] = []
	var sfUtils = SFUtilities()
	var masterAccountId: String = ""
	var caseId: String = ""
	var mapSnapshot: UIImage?

	override func viewDidLoad() {
		super.viewDidLoad()
		//Setup Mapview
		initMapViewExt()
		//Recording Setup
		initAVRecordingExt()
		//Setup Camera, and Image access
		initImageExt()
		//Setup contact access
		initContactsExt()
	
	}
	
	@IBAction func submitClaim(_ sender: Any) {
		UploadClaimTransaction()
	}
}
