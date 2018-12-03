//
//  NewClaimCtrl+Images.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/29/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

extension NewClaimCtrl: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

	func initImageExt(){
		photoCollectionView.delegate = self
		photoCollectionView.dataSource = self
		photoCollectionView.layer.borderWidth = 1
		photoCollectionView.layer.borderColor = UIColor.black.cgColor
	}
	
	@IBAction func onSelectPhotoTouched(_ sender: Any){
		imagePickerCtrl = UIImagePickerController()
		imagePickerCtrl.delegate = self
		imagePickerCtrl.sourceType = .camera
		present(imagePickerCtrl, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		imagePickerCtrl.dismiss(animated: true, completion: nil)
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			selectedImages.append(image)
			photoCollectionView.reloadData()
		}
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return selectedImages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageReuseableIdentifier", for: indexPath) as! SelectedImagesCell
		let image = selectedImages[indexPath.row]
		cell.imageView.image = image
		return cell
	}
}
