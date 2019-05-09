//
//  NewClaimViewController+Contacts.swift
//  Codey's Car Insurance Project
//
//  Created by Kevin Poorman on 11/29/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

extension NewClaimViewController: CNContactViewControllerDelegate, CNContactPickerDelegate {

	func presentContactPicker() {
		contactPicker.delegate = self
		self.present(contactPicker, animated: true, completion: nil)
	}

	func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
		contactPicker.dismiss(animated: true)
		self.contacts = contacts
		
		// clean up stack view.
		for view in partiesInvolvedStackView.arrangedSubviews {
			partiesInvolvedStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
		
		// Add an entry in the stack view for each contact.
		for contact in contacts {
			partiesInvolvedStackView.addArrangedSubview(contactStackView(for: contact))
		}
	}
	
	/// Sets up a stack view for the contact with its name, email and a separator.
	///
	/// - Parameter contact: The contact to be used to set up the stack view.
	/// - Returns: A stack view for the contact.
	func contactStackView(for contact: CNContact) -> UIStackView {
		let contactNamelabel = UILabel()
		contactNamelabel.font = UIFont.preferredFont(forTextStyle: .headline)
		contactNamelabel.text = CNContactFormatter.string(from: contact, style: .fullName)
		
		let contactEmailLabel = UILabel()
		contactEmailLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
		contactEmailLabel.text = (contact.emailAddresses.first?.value ?? "") as String
		
		// A 1pt separator.
		let separator = UIView()
		separator.backgroundColor = UIColor(named: "separator")
		separator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		
		let contactStackView = UIStackView(arrangedSubviews: [contactNamelabel, contactEmailLabel, separator])
		contactStackView.axis = .vertical
		contactStackView.spacing = 4
		return contactStackView
	}

	func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
		viewController.dismiss(animated: true, completion: nil)
	}

	func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
		return true
	}
}
