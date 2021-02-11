//
//  UIImageExtensions.swift
//  RedwoodsInsurance
//
//  Created by Kevin Poorman on 2/3/20.
//  Copyright © 2020 RedwoodsInsuranceOrganizationName. All rights reserved.
//

import Foundation
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
