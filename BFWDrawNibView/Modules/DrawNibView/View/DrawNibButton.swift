//
//  DrawNibButton.swift
//  BFWDrawNibView
//
//  Created by Tom Brodhurst-Hill on 25/11/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit
import BFWControls
import BFWDrawView

// TODO: Facilitate different drawing images for each state.

open class DrawNibButton: NibButton {
    
    open var drawingImageView: DrawingImageView? {
        return imageView as? DrawingImageView
    }
    
    @IBInspectable open var drawingStyleKit: String? {
        get {
            return drawingImageView?.styleKit
        }
        set {
            drawingImageView?.styleKit = newValue
        }
    }
    
    @IBInspectable open var drawingName: String? {
        get {
            return drawingImageView?.name
        }
        set {
            drawingImageView?.name = newValue
        }
    }
    
}
