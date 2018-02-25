//
//  AnimationView.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 20/05/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

@IBDesignable open class AnimationView: DrawingView {
    
    public enum Curve: Int {
        
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
                    let outside = pow(2.0, -10 * t) * sin((t - p / 4) * (2 * .pi) / p) + 1
                    return outside / max
                }
            }
        }
    }
    
    // MARK: - Variables
    
    /// Fraction 0.0 to 1.0. Set internally but exposed for storyboard preview.
    @IBInspectable open dynamic var animation: Double = 0.0 {
        didSet {
//            updateArgument(forParameter: "animation")
            setNeedsDraw()
        }
    }
    
    /// Fraction 0.0 to 1.0. Start of animation.
    @IBInspectable open var start: Double = 0.0
    
    /// Fraction 0.0 to 1.0. End of animation.
    @IBInspectable open var end: Double = 1.0
    
    @IBInspectable open var duration: Double = 3.0
    
    /// Default 0 = infinite cycles (repetitions).
    @IBInspectable open var cycles: Double = 0.0
    
    @IBInspectable open var cycleDelay: Double = 0.0
    
    @IBInspectable open var isPaused: Bool {
        get {
            return pausedDate != nil
        }
        set {
            if isPaused != newValue {
                if newValue {
                    pausedDate = Date()
                    timer?.invalidate()
                    timer = nil
                } else {
                    if let _ = startDate,
                        let pausedDate = pausedDate
                    {
                        let morePausedTimeInterval = Date().timeIntervalSince(pausedDate)
                        pausedTimeInterval += morePausedTimeInterval
                    }
                    pausedDate = nil
                    startAnimationTimerIfNeeded()
                }
            }
        }
    }
    
    open var framesPerSecond = 30.0
    
    open var curve: Curve = .linear
    
    @IBInspectable open var curve_: Int {
        get {
            return curve.rawValue
        }
        set {
            curve = Curve(rawValue: newValue) ?? .linear
        }
    }
    
    // MARK: Public diagnostic variables
    
    open var drawnFramesPerSecond: Double {
        var framesPerSecond = 0.0
        if let startDate = startDate {
            let interval = Date().timeIntervalSince(startDate)
            if interval > 0 {
                framesPerSecond = Double(drawnFrameCount) / interval
            }
        }
        return framesPerSecond
    }
    
    // MARK: Private variables
    
    fileprivate weak var timer: Timer? // Weak because NSRunLoop holds a strong reference
    fileprivate var startDate: Date?
    fileprivate var pausedDate: Date?
    fileprivate var pausedTimeInterval: TimeInterval = 0.0
    fileprivate var completedCycles: Double = 0
    fileprivate var isFinished = false
    fileprivate var drawnFrameCount: UInt = 0 // to count actual frames drawn
    
    open var animationBetweenStartAndEnd: CGFloat {
        var curved = curve.function(animation)
        if start != 0.0 || end != 0.0 {
            curved = start + curved * (end - start)
        }
        return CGFloat(curved)
    }
    
    fileprivate var isAnimation: Bool {
        return parameters.contains("animation") 
    }
    
    // MARK: - Animation
    
    open func restart() {
        pausedDate = nil
        timer?.invalidate()
        timer = nil
        isFinished = false
        startDate = nil
        startAnimationTimerIfNeeded()
    }
    
    fileprivate func startAnimationTimerIfNeeded() {
        if timer == nil && !isPaused && !isFinished && isAnimation {
            if startDate == nil {
                startDate = Date()
                drawnFrameCount = 0
                completedCycles = 0
            }
            startNextAnimation()
        }
    }
    
    fileprivate func startDelayTimer() {
        timer = Timer.scheduledTimer(timeInterval: cycleDelay,
                                     target: self,
                                     selector: #selector(startNextAnimation),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    open func startNextAnimation() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0 / Double(framesPerSecond),
                                          target: self,
                                          selector: #selector(animate(timer:)),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    open func animate(timer: Timer) {
        if isPaused || superview == nil {
            timer.invalidate()
            self.timer = nil
        } else {
            let animatedTimeInterval = Date().timeIntervalSince(startDate!) - pausedTimeInterval - completedCycles * cycleDelay
            let completedAnimation = animatedTimeInterval / duration - completedCycles
            if completedAnimation >= 1.0 {
                animation = 1.0 // Ensure that it draws the final frame.
                completedCycles += 1
                isFinished = cycles > 0.0 && completedCycles >= cycles
                timer.invalidate()
                self.timer = nil
                if !isFinished {
                    startDelayTimer()
                }
            } else {
                animation = completedAnimation
            }
        }
    }
    
    open func writeImages(at scale: CGFloat,
                          isOpaque: Bool,
                          to fileURL: URL) -> Bool
    {
        var success = false
        if isPaused {
            success = writeImage(at: scale,
                                 isOpaque: isOpaque,
                                 to: fileURL)
        } else {
            let frameCount = duration * framesPerSecond
            let digits = Int(log10(frameCount) + 1)
            let fileExtension = fileURL.pathExtension
            let baseName = fileURL.deletingPathExtension().lastPathComponent
            let nameFormat = baseName + "%0\(digits)d"
            let directory = fileURL.deletingLastPathComponent()
            for frameN in 0 ..< Int(frameCount) {
                animation = Double(frameN) / frameCount
                let fileName = String(format: nameFormat, frameN)
                let frameURL = directory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
                let frameSuccess = writeImage(at: scale,
                                              isOpaque: isOpaque,
                                              to: frameURL)
                success = (success || frameN == 0) && frameSuccess
            }
        }
        return success
    }
    
    // MARK: - UIView
    
    open override func draw(_ rect: CGRect) {
        startAnimationTimerIfNeeded()
        drawnFrameCount += 1
        super.draw(rect)
    }
    
    open override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set {
            let wasHidden = super.isHidden
            super.isHidden = newValue
            if newValue != wasHidden {
                if newValue {
                    timer?.invalidate()
                } else {
                    startAnimationTimerIfNeeded()
                }
            }
        }
    }
    
}

extension AnimationView {
    
    // MARK: - DrawingView
    
    override var handledParametersArray: [[String]] {
        return super.handledParametersArray.map { $0 + ["animation"] }
    }
    
    override func draw(parameters: [String]) -> Bool {
        var success = false
        if let drawingSelector = drawingSelector,
            let styleKitClass = drawing?.styleKit.paintCodeClass
        {
            success = true
            if parameters == ["frame", "animation"] {
                if let drawFunction = drawRectAnimationFunction(from: styleKitClass, selector: drawingSelector) {
                    drawFunction(drawFrame, animationBetweenStartAndEnd)
                }
            } else if parameters == ["frame", "tintColor", "animation"] {
                if let drawFunction = drawRectColorAnimationFunction(from: styleKitClass, selector: drawingSelector) {
                    drawFunction(drawFrame, tintColor, animationBetweenStartAndEnd)
                }
            } else {
                success = super.draw(parameters: parameters)
            }
        }
        return success
    }
    
    func drawRectAnimationFunction(from owner: AnyObject, selector: Selector) -> ((CGRect, CGFloat) -> Void)? {
        typealias CFunction = @convention(c) (AnyObject, Selector, CGRect, CGFloat) -> Void
        let implementation = self.implementation(for: owner, selector: selector)
        let cFunction = unsafeBitCast(implementation, to: CFunction.self)
        return { rect, animation in
            cFunction(owner, selector, rect, animation)
        }
    }
    
    func drawRectColorAnimationFunction(from owner: AnyObject, selector: Selector) -> ((CGRect, UIColor, CGFloat) -> Void)? {
        typealias CFunction = @convention(c) (AnyObject, Selector, CGRect, UIColor, CGFloat) -> Void
        let implementation = self.implementation(for: owner, selector: selector)
        let cFunction = unsafeBitCast(implementation, to: CFunction.self)
        return { rect, tintColor, animation in
            cFunction(owner, selector, rect, tintColor, animation)
        }
    }
    
}
