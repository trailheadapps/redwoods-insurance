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
	func halfSize() -> UIImage? {
		
		let imageView = UIImageView(frame: CGRect(origin: .zero,
																							size: CGSize(width: size.width * 0.5, height: size.height * 0.5)))
		imageView.contentMode = .scaleAspectFit
		imageView.image = self
		
		
		UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		imageView.layer.render(in: context)
		guard let result = UIGraphicsGetImageFromCurrentImageContext() else {
			return nil
		}
		UIGraphicsEndImageContext()
		return result
	}

	func ResizeImage() -> UIImage? {
		let size = self.size
		
		let newSize = CGSize(width:size.width * 0.5, height:size.height * 0.5)

		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(origin: .zero, size:newSize)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)
		guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
			return nil
		}
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
}
