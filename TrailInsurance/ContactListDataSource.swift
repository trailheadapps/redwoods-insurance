//
//  ContactListDataSource.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 12/3/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

class ContactListDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

	var contacts: [CNContact] = [CNContact]()

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return contacts.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "contactRowReuseIdentifier", for: indexPath)
		let obj = contacts[indexPath.row]
		if let name = CNContactFormatter.string(from: obj, style: .fullName) {
			cell.textLabel?.text = name
		}
		cell.detailTextLabel?.text = (obj.emailAddresses.first?.value ?? "") as String
		return cell
	}

}
