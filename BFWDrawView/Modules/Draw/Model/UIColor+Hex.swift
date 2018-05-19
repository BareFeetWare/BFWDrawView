//
//  UIColor+Hex.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 18/05/2015.
//  Triggered by refactoring by Tom Jowett on 9/05/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import Foundation

extension UIColor {
    
    func hex(fromFraction fraction: CGFloat) -> String {
        let decimalInt = Int(round(fraction * 255.0))
        let hexString = String(format: "%02lx", decimalInt)
        return hexString
    }
    
    func hex(includingAlpha: Bool) -> String {
        var red: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var green: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        if self == UIColor.white {
            // Special case, as white doesn't fall into the RGB color space
            red = 1.0
            green = 1.0
            blue = 1.0
            alpha = 1.0
        } else {
            getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        }
        let redHex = hex(fromFraction: red)
        let blueHex = hex(fromFraction: blue)
        let greenHex = hex(fromFraction: green)
        var hexArray = [redHex, greenHex, blueHex]
        if includingAlpha {
            let alphaHex = hex(fromFraction: alpha)
            hexArray = [alphaHex] + hexArray
        }
        let colorHex = hexArray.joined(separator: "")
        return colorHex
    }
    
    var hexString: String {
        return hex(includingAlpha: true)
    }
    
    var cssHexString: String {
        return hex(includingAlpha: false)
    }
    
}
