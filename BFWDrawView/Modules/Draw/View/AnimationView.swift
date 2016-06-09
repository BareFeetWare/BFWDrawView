//
//  AnimationView.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 20/05/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

/// AnimationView is a Swift class that will eventually replace BFWAnimationView
@IBDesignable class AnimationView: BFWAnimationView {

    enum Curve: Int {
        
        case linear = 0
        case easeOutElastic = 1
        
        var function: (Double) -> Double {
            switch self {
            case .linear: return { t in t }
            case .easeOutElastic:
                return { t in
                    let p = 0.3
                    return pow(2.0, -10 * t) * sin((t - p / 4) * (2 * M_PI) / p) + 1
                }
            }
        }
    }
    
    var curve: Curve = .linear
    
    @IBInspectable var curve_: Int {
        get {
            return curve.rawValue
        }
        set {
            curve = Curve(rawValue: newValue) ?? .linear
        }
    }
    
    var animationBetweenStartAndEnd: Double {
        let t = animation as Double
        return curve.function(t)
    }
    
}