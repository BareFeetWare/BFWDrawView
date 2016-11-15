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
        case easeInOut = 1
        case easeIn = 2
        case easeOut = 3
        case easeOutElastic = 4
        
        var function: (Double) -> Double {
            switch self {
            case .linear: return { t in t }
            case .easeInOut:
                return { t in
                    let easeIn = Curve.easeIn.function
                    return t < 0.5 ? easeIn(t * 2.0) / 2.0 : 1.0 - easeIn((1.0 - t ) * 2) / 2
                }
            case .easeIn: return { t in pow(t, 3.0) }
            case .easeOut: return { t in 1.0 - pow(1.0 - t, 3.0) }
            case .easeOutElastic:
                return { t in
                    let p = 0.3
                    let max = 1.375
                    let outside = pow(2.0, -10 * t) * sin((t - p / 4) * (2 * M_PI) / p) + 1
                    return outside / max
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
    
    // Overriding BFWAnimationView
    
    var animationBetweenStartAndEnd: CGFloat {
        var curved = curve.function(animation)
        if start != 0.0 || end != 0.0 {
            curved = start + curved * (end - start)
        }
        return CGFloat(curved)
    }
    
}
