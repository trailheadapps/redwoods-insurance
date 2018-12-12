//
//  UIImage+resize.swift
//  TrailInsurance
//
//  Created by Kevin Poorman on 12/2/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	func resizeImageByHalf() -> UIImage? {
		let newSize = CGSize(width: self.size.width * 0.5, height: self.size.height * 0.5)
		let rect = CGRect(origin: .zero, size: newSize)

		// resize the image
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)
		guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
			return nil
		}
		UIGraphicsEndImageContext()

		return newImage
	}

}
