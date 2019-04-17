//
//  NewClaimViewController.swift
//  Codey's Car Insurance Project
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

	// MARK: - Incident Location
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var addressLabel: UILabel!
	
	// MARK: - Incident Description
	@IBOutlet weak var transcriptionTextView: UITextView!
	@IBOutlet weak var recordingTimerLabel: UILabel!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var recordButton: UIButton!
	
	// MARK: - Photos of Damages
	@IBOutlet weak var photoStackView: UIStackView!
	@IBOutlet weak var photoStackHeightConstraint: NSLayoutConstraint!
	
	// MARK: - Parties Involved
	@IBOutlet weak var partiesInvolvedStackView: UIStackView!
	
	// MARK: - New Claim properties
	var wasSubmitted = false
	
	let locationManager = CLLocationManager()
	let regionRadius = 150.0
	let geoCoder = CLGeocoder()
	var geoCodedAddress: CLPlacemark?
	var geoCodedAddressText = ""
	
	var recordingSession: AVAudioSession!
	var incidentRecorder: AVAudioRecorder?
	var audioPlayer: AVAudioPlayer!
	var meterTimer: Timer?
	var transcribedText = ""
	var isPlaying = false
	
	var imagePickerCtrl: UIImagePickerController!
	var selectedImages: [UIImage] = []
	
	var contacts: [CNContact] = []
	let contactPicker = CNContactPickerViewController()

	var alert:UIAlertController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//Setup Mapview
		initMapViewExtension()
		//Recording Setup
		initAVRecordingExtension()
		self.transcriptionTextView.delegate = self
	
	}

	// MARK: - Actions
	@IBAction func submitClaim(_ sender: UIBarButtonItem) {
		uploadClaimTransaction()
	}
	
	@IBAction func playPauseAudioTapped(_ sender: UIButton) {
		toggleAudio()
	}
	
	@IBAction func startOrStopRecordingTapped(_ sender: UIButton) {
		toggleRecording()
	}
	
	@IBAction func addPhotoTapped(_ sender: UIButton) {
		addPhoto()
	}
	
	@IBAction func editInvolvedPartiesTapped(_ sender: UIButton) {
		presentContactPicker()
	}
}

extension NewClaimViewController: UITextViewDelegate {
	func textViewDidEndEditing(_ textView: UITextView) {
		self.transcribedText = self.transcriptionTextView.text
	}
}
