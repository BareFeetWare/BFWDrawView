//
//  DrawingView+Morphable.swift
//  BFWDrawNibView
//
//  Created by Tom Brodhurst-Hill on 24/9/17.
//  Copyright © 2017 BareFeetWare. Free to use and modify, without warranty.
//

import UIKit
import BFWDrawView
import BFWControls

public extension Morphable where Self: DrawingView {

    public func copyProperties(from view: UIView) {
        guard let drawingView = view as? DrawingView
            else { return }
        (self as UIView).copyProperties(from: view)
        styleKit = drawingView.styleKit
        name = drawingView.name
        drawing = drawingView.drawing
    }
    
}

public extension Morphable where Self: AnimationView {

    public func copyProperties(from view: UIView) {
        guard let animationView = view as? AnimationView
            else { return }
        (self as DrawingView).copyProperties(from: view)
        animationView.curve = curve
        animationView.cycles = cycles
        animationView.duration = duration
        animationView.isPaused = isPaused
        animationView.animation = animation
        animationView.start = start
        animationView.end = end
        animationView.framesPerSecond = framesPerSecond
    }
    
}
