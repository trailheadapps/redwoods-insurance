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
	
	func initContactsExt() {
		
	}
	
	@IBAction func onAddExistingContactTouched(_ sender: Any) {
		contactPicker.delegate = self
		self.present(contactPicker, animated: true, completion: nil)
	}
	
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
		contactPicker.dismiss(animated: true)
		self.contacts = contacts
		let sfUtils = SFUtilities()
		
		for contact in contacts {
			if let name = CNContactFormatter.string(from: contact, style: .fullName){
				print("contact data: " + name)
				for number in contact.phoneNumbers {
					if let phone = number.value.value(forKey: "digits") as? String {
						print("Contact #: " + phone)
					}
				}
			}
		}
	}
	
	func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
		print("Dismiss Contact")
		viewController.dismiss(animated: true, completion: nil)
		
	}
	
	func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
		return true
	}
}
