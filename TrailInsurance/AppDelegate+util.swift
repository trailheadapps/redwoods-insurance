//
//  AppDelegate+util.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 11/30/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit

extension AppDelegate {
	
	func showMessage(message: String) {
		let alertController = UIAlertController(title: "Birthdays", message: message, preferredStyle: UIAlertControllerStyle.alert)
		
		let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
		}
		
		alertController.addAction(dismissAction)
		
		let pushedViewControllers = (self.window?.rootViewController as! UINavigationController).viewControllers
		let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
		
		presentedViewController.present(alertController, animated: true, completion: nil)
	}

	class func getAppDelegate() -> AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}
}
