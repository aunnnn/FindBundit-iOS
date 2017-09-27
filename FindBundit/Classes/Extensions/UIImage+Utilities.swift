//
//  UIImage+Utilities.swift
//  FindBundit
//
//  Created by Wirawit Rueopas on 10/19/2559 BE.
//  Copyright © 2559 Wirawit Rueopas. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWithSize(newSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}