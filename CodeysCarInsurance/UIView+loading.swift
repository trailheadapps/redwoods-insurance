//
//  UIView+loading.swift
//  Codey's Car Insurance Project
//
//  Created by Kevin Poorman on 11/26/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit

private var ActivityIndicatorViewAssociativeKey = "ActivityIndicatorViewAssociativeKey"

extension UIView {
	var activityIndicatorView: UIActivityIndicatorView {
		get {
			if let activityIndicatorView = objc_getAssociatedObject(self, &ActivityIndicatorViewAssociativeKey) as? UIActivityIndicatorView {
				return activityIndicatorView
			} else {
				let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
				activityIndicatorView.style = .whiteLarge
				activityIndicatorView.color = .gray
				activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2) //center
				activityIndicatorView.hidesWhenStopped = true
				addSubview(activityIndicatorView)

				objc_setAssociatedObject(self, &ActivityIndicatorViewAssociativeKey, activityIndicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
				return activityIndicatorView
			}
		}

		set {
			addSubview(newValue)
			objc_setAssociatedObject(self, &ActivityIndicatorViewAssociativeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}

	}
}
