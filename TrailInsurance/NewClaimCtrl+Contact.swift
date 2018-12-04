//
//  NewClaimCtrl+Contact.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/29/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

extension NewClaimCtrl: CNContactViewControllerDelegate, CNContactPickerDelegate {
	
	@IBAction func onAddExistingContactTouched(_ sender: Any) {
		contactPicker.delegate = self
		self.present(contactPicker, animated: true, completion: nil)
	}
	
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
		contactPicker.dismiss(animated: true)
		self.contactListData.contacts = contacts
		self.contactList.reloadData()
	}
	
	func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
		viewController.dismiss(animated: true, completion: nil)
	}
	
	func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
		return true
	}
}
