//
//  AnimationView+Copy.swift
//
//  Created by Tom Brodhurst-Hill on 8/1/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

extension AnimationView {
    
    override func copyProperties(from view: UIView) {
        super.copyProperties(from: view)
        if let view = view as? AnimationView {
            animation = view.animation
            start = view.start
            end = view.end
            duration = view.duration
            cycles = view.cycles
            isPaused = view.isPaused
            framesPerSecond = view.framesPerSecond
        }
    }

}
