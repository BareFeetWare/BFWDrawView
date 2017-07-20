//
//  DrawingButton.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 9/07/2016.
//  Copyright (c) 2016 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

@IBDesignable open class DrawingButton: UIButton {
    
    // MARK: - Variables
    
    private var iconDrawViewForStateDict = [UInt: DrawingView]()
    private var backgroundDrawViewForStateDict = [UInt: DrawingView]() { didSet { setNeedsUpdateBackgrounds() }}
    private var shadowForStateDict = [UInt: NSShadow]()
    private var needsUpdateShadow = true
    private var backgroundSize = CGSize.zero
    
    @IBInspectable open var iconName: String? {
        didSet {
            setNeedsUpdateView()
        }
    }
    
    @IBInspectable open var iconStyleKit: String? {
        didSet {
            setNeedsUpdateView()
        }
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    open func commonInit() {
        // Implement in subclasses if required and call super.
    }
    
    // MARK: - Accessors for state
    
    open func iconDrawView(for state: UIControlState) -> DrawingView? {
        return iconDrawViewForStateDict[state.rawValue]
    }
    
    open func backgroundDrawView(for state: UIControlState) -> DrawingView? {
        return backgroundDrawViewForStateDict[state.rawValue]
    }
    
    open func setIconDrawView(_ drawingView: DrawingView?, for state: UIControlState) {
        iconDrawViewForStateDict.setValueOrRemoveNil(drawingView,
                                                     forKey: state.rawValue)
        setImage(drawingView?.image, for: state)
    }
    
    open func setBackgroundDrawView(_ drawingView: DrawingView?, for state: UIControlState) {
        backgroundDrawViewForStateDict.setValueOrRemoveNil((drawingView?.canDraw ?? false) ? drawingView : nil,
                                                           forKey: state.rawValue)
    }
    
    open func shadow(for state: UIControlState) -> NSShadow? {
        return shadowForStateDict[state.rawValue]
    }
    
    open func setShadow(_ shadow: NSShadow?, for state: UIControlState) {
        shadowForStateDict.setValueOrRemoveNil(shadow, forKey: state.rawValue)
        setNeedsUpdateShadow()
    }
    
    fileprivate func setNeedsUpdateShadow() {
        needsUpdateShadow = true
        setNeedsDisplay()
    }
    
    fileprivate func setNeedsUpdateBackgrounds() {
        backgroundSize = CGSize.zero
        setNeedsLayout()
    }
    
    fileprivate var needsUpdateBackgrounds: Bool {
        return backgroundSize != bounds.size
    }
    
    // MARK: - Updates
    
    fileprivate func updateBackgrounds() {
        for state: UIControlState in [.normal, .disabled, .selected, .highlighted] {
            let background = backgroundDrawViewForStateDict[state.rawValue]
            background?.frame = bounds
            setBackgroundImage(background?.image, for: state)
        }
    }
    
    fileprivate func updateBackgroundsIfNeeded() {
        if needsUpdateBackgrounds {
            backgroundSize = bounds.size
            updateBackgrounds()
        }
    }
    
    fileprivate func updateShadowIfNeeded() {
        if needsUpdateShadow {
            needsUpdateShadow = false
            let shadow = self.shadow(for: state) ?? self.shadow(for: .normal)
            apply(shadow: shadow)
        }
    }
    
    // MARK: - UIButton
    
    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            setNeedsUpdateShadow()
        }
    }
    
    open override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            setNeedsUpdateShadow()
        }
    }
    
    open override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            setNeedsUpdateShadow()
        }
    }
    
    // MARK: - Functions
    
    open func makeIcon(name: String,
                       styleKit: String,
                       state: UIControlState,
                       tintColor: UIColor,
                       size: CGSize?)
    {
        if let drawing = StyleKit.drawing(forStyleKitName: styleKit,
                                          drawingName: name)
        {
            let frame: CGRect?
            if let size = size, size != CGSize.zero {
                frame = CGRect(origin: CGPoint.zero, size: size)
            } else {
                frame = drawing.intrinsicFrame
            }
            if let frame = frame {
                let icon = DrawingView(frame: frame)
                icon.drawing = drawing
                icon.tintColor = tintColor
                icon.contentMode = .redraw
                setIconDrawView(icon, for: state)
            }
        }
    }
    
    open func makeIconDrawViews(from stateNameDict: [UInt: String],
                                styleKit: String)
    {
        iconDrawViewForStateDict.removeAll()
        for (stateInt, drawingName) in stateNameDict {
            if let drawing = StyleKit.drawing(forStyleKitName: styleKit,
                                              drawingName: drawingName),
                let frame = drawing.intrinsicFrame
            {
                let icon = DrawingView(frame: frame)
                icon.drawing = drawing
                icon.tintColor = tintColor
                icon.contentMode = .redraw
                setIconDrawView(icon, for: UIControlState(rawValue: stateInt))
            }
        }
    }
    
    open func makeBackgroundDrawViews(from stateNameDict: [UInt: String],
                                      styleKit: String)
    {
        backgroundDrawViewForStateDict.removeAll()
        for (stateInt, drawingName) in stateNameDict {
            let background = DrawingView(frame: self.bounds)
            background.drawing = StyleKit.drawing(forStyleKitName: styleKit,
                                                  drawingName: drawingName)
            background.contentMode = .redraw
            setBackgroundDrawView(background,
                                  for: UIControlState(rawValue: stateInt))
        }
    }
    
    // MARK: - UpdateView
    
    open func setNeedsUpdateView() {
        needsUpdateView = true
        setNeedsLayout()
    }
    
    fileprivate var needsUpdateView = true
    
    open func updateView() {
        if let iconName = iconName,
            let iconStyleKit = iconStyleKit
        {
            makeIconDrawViews(from: [UIControlState.normal.rawValue: iconName],
                              styleKit: iconStyleKit)
        }
    }
    
    fileprivate func updateViewIfNeeded() {
        if needsUpdateView {
            needsUpdateView = false
            updateView()
        }
    }
    
    // MARK: - UIView
    
    open override func layoutSubviews() {
        updateBackgroundsIfNeeded()
        updateViewIfNeeded()
        super.layoutSubviews()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateShadowIfNeeded()
    }
    
}

fileprivate extension Dictionary {
    
    mutating func setValueOrRemoveNil(_ valueOrNil: Value?, forKey key: Key) {
        if let value = valueOrNil {
            self[key] = value
        } else {
            self.removeValue(forKey: key)
        }
    }
    
}

fileprivate extension UIView {
    
    func apply(shadow: NSShadow?) {
        if let shadowColor = shadow?.shadowColor as? UIColor {
            layer.shadowColor = shadowColor.cgColor
        }
        layer.shadowRadius = shadow?.shadowBlurRadius ?? 0.0
        layer.shadowOffset = shadow?.shadowOffset ?? CGSize.zero
        layer.shadowOpacity = shadow != nil ? 1.0 : 0.0
        layer.masksToBounds = shadow == nil
    }
    
}
