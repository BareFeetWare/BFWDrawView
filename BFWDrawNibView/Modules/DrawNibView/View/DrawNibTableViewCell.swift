//
//  DrawNibTableViewCell.swift
//  BFWDrawNibView
//
//  Created by Tom Brodhurst-Hill on 29/1/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit
import BFWControls
import BFWDrawView

open class DrawNibTableViewCell: NibTableViewCell {

    // MARK - Variables
    
    open var drawingImageView: DrawingImageView? {
        return imageView as? DrawingImageView
    }

    @IBInspectable open var name: String? {
        get {
            return drawingImageView?.name
        }
        set {
            drawingImageView?.name = newValue
        }
    }
    
    @IBInspectable open var styleKit: String? {
        get {
            return drawingImageView?.styleKit
        }
        set {
            drawingImageView?.styleKit = newValue
        }
    }

}
