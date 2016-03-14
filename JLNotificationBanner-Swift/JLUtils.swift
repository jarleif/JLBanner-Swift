//
//  JLUtils.swift
//  JLNotificationBanner-Swift
//
//  Created by Jared LaSante on 3/14/16.
//  Copyright © 2016 Jared LaSante. All rights reserved.
//

import UIKit

class JLUtils: NSObject {

    class func imageWithGradient(colorsArray: [UIColor], imageHeight: CGFloat) -> UIImage
    {
        return JLUtils.imageWithGradient(colorsArray, imageHeight: imageHeight, imageWidth: 1)
    }
    
    class func imageWithGradient(colorsArray: [UIColor], imageHeight: CGFloat, imageWidth: CGFloat) -> UIImage
    {
        UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight))
        let context = UIGraphicsGetCurrentContext()
    
    // Create gradient.
        let gradientColors = colorsArray.map {(color: UIColor!) -> AnyObject! in return color.CGColor as AnyObject! } as NSArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations = UnsafePointer<CGFloat>()
        let gradient = CGGradientCreateWithColors(colorSpace, gradientColors, locations)
        
        // Create image.
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, imageHeight), CGGradientDrawingOptions.DrawsAfterEndLocation)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return image
    }
}
