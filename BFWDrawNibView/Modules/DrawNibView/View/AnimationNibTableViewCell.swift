//
//  AnimationNibTableViewCell.swift
//  BFWDrawNibView
//
//  Created by Tom Brodhurst-Hill on 10/2/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit
import BFWDrawView

@IBDesignable open class AnimationNibTableViewCell: DrawNibTableViewCell {

    open var animationView: AnimationView? {
        return drawingView as? AnimationView
    }
    
    @IBInspectable open var animation: Double {
        get {
            return animationView?.animation ?? 0.0
        }
        set {
            animationView?.animation = newValue
        }
    }
    
    @IBInspectable open var start: Double {
        get {
            return animationView?.start ?? 0.0
        }
        set {
            animationView?.start = newValue
        }
    }
    
    @IBInspectable open var end: Double {
        get {
            return animationView?.end ?? 0.0
        }
        set {
            animationView?.end = newValue
        }
    }
    
    @IBInspectable open var duration: Double {
        get {
            return animationView?.duration ?? 0.0
        }
        set {
            animationView?.duration = newValue
        }
    }
    
    @IBInspectable open var cycles: Double {
        get {
            return animationView?.cycles ?? 0.0
        }
        set {
            animationView?.cycles = newValue
        }
    }
    
    @IBInspectable open var isPaused: Bool {
        get {
            return animationView?.isPaused ?? true
        }
        set {
            animationView?.isPaused = newValue
        }
    }

}
