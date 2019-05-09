//
//  UIImage+resize.swift
//  Codey's Car Insurance Project
//
//  Created by Kevin Poorman on 12/2/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

extension UIImage {
	func resizedByHalf() -> UIImage {
		let newSize = CGSize(width: self.size.width * 0.5, height: self.size.height * 0.5)
		let rect = CGRect(origin: .zero, size: newSize)

		// resize the image
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		return newImage
	}
}
