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
        
        case Linear = 0
        case EaseInOut = 1
        case EaseIn = 2
        case EaseOut = 3
        case EaseOutElastic = 4
        
        var function: (Double) -> Double {
            switch self {
            case .Linear: return { t in t }
            case .EaseInOut:
                return { t in
                    let easeIn = Curve.EaseIn.function
                    return t < 0.5 ? easeIn(t * 2.0) / 2.0 : 1.0 - easeIn((1.0 - t ) * 2) / 2
                }
            case .EaseIn: return { t in pow(t, 3.0) }
            case .EaseOut: return { t in 1.0 - pow(1.0 - t, 3.0) }
            case .EaseOutElastic:
                return { t in
                    let p = 0.3
                    let max = 1.375
                    let outside = pow(2.0, -10 * t) * sin((t - p / 4) * (2 * M_PI) / p) + 1
                    return outside / max
                }
            }
        }
    }
    
    var curve: Curve = .Linear
    
    @IBInspectable var curve_: Int {
        get {
            return curve.rawValue
        }
        set {
            curve = Curve(rawValue: newValue) ?? .Linear
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
