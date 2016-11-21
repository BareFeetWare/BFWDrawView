//
//  DrawingButton.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 9/07/2016.
//  Copyright (c) 2016 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

@IBDesignable class DrawingButton: UIButton {

    // MARK: - Variables

    private var iconDrawViewForStateDict = [NSNumber: DrawingView]()
    private var backgroundDrawViewForStateDict = [NSNumber: DrawingView]()
    private var shadowForStateDict = [NSNumber: NSShadow]()
    private var needsUpdateShadow = true
    private var backgroundSize = CGSize.zero

    @IBInspectable var iconName: String? {
        didSet {
            setNeedsUpdateView()
        }
    }
    
    @IBInspectable var iconStyleKit: String? {
        didSet {
            setNeedsUpdateView()
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        // Implement in subclasses if required and call super.
    }
    
    // MARK: - Accessors for state
    
    func iconDrawView(for state: UIControlState) -> DrawingView? {
        return iconDrawViewForStateDict[NSNumber(value: state.rawValue)]
    }
    
    func backgroundDrawView(for state: UIControlState) -> DrawingView? {
        return backgroundDrawViewForStateDict[NSNumber(value: state.rawValue)]
    }
    
    func setIconDrawView(_ drawView: DrawingView, for state: UIControlState) {
        iconDrawViewForStateDict.setValueOrRemoveNil(drawView, forKey: NSNumber(value: state.rawValue))
        setImage(drawView.image, for: state)
    }
    
    func setBackgroundDrawView(_ drawView: DrawingView, for state: UIControlState) {
        backgroundDrawViewForStateDict.setValueOrRemoveNil(drawView.canDraw ? drawView : nil, forKey: NSNumber(value: state.rawValue))
        setNeedsUpdateBackgrounds()
    }
    
    func shadow(for state: UIControlState) -> NSShadow? {
        return shadowForStateDict[NSNumber(value: state.rawValue)]
    }
    
    func setShadow(_ shadow: NSShadow, for state: UIControlState) {
        shadowForStateDict.setValueOrRemoveNil(shadow, forKey: NSNumber(value: state.rawValue))
        setNeedsUpdateShadow()
    }

    func setNeedsUpdateShadow() {
        needsUpdateShadow = true
        setNeedsDisplay()
    }
    
    func setNeedsUpdateBackgrounds() {
        backgroundSize = CGSize.zero
        setNeedsLayout()
    }
    
    var needsUpdateBackgrounds: Bool {
        return backgroundSize != bounds.size
    }
    
    // MARK: - Updates
    
    func updateBackgrounds() {
        for state: UIControlState in [.normal, .disabled, .selected, .highlighted] {
            if let background = backgroundDrawViewForStateDict[NSNumber(value: state.rawValue)] {
                background.frame = bounds
                setBackgroundImage(background.image, for: state)
            }
        }
    }
    
    func updateBackgroundsIfNeeded() {
        if needsUpdateBackgrounds {
            backgroundSize = bounds.size
            updateBackgrounds()
        }
    }
    
    func updateShadowIfNeeded() {
        if needsUpdateShadow {
            needsUpdateShadow = false
            let shadow = self.shadow(for: state) ?? self.shadow(for: .normal)
            apply(shadow: shadow)
        }
    }
    
    // MARK: - UIButton
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            super.isHighlighted = newValue
            setNeedsUpdateShadow()
        }
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            setNeedsUpdateShadow()
        }
    }
    
    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            setNeedsUpdateShadow()
        }
    }
    
    // MARK: - Functions
    
    func makeIconWithSize(size: CGSize?,
                          name: String,
                          styleKit: String,
                          state: UIControlState,
                          tintColor: UIColor)
    {
        if let drawing = BFWStyleKit.drawing(forStyleKitName: styleKit,
                                             drawingName: name)
        {
            let frame: CGRect
            if let size = size, size != CGSize.zero {
                frame = CGRect(origin: CGPoint.zero, size: size)
            } else {
                frame = drawing.intrinsicFrame
            }
            let icon = DrawingView(frame: frame)
            icon.drawing = drawing
            icon.tintColor = tintColor
            icon.contentMode = .redraw
            setIconDrawView(icon, for: state)
        }
    }

    
    func makeIconDrawViews(from stateNameDict: [NSNumber: String], styleKit: String) {
        iconDrawViewForStateDict.removeAll()
        for (stateNumber, drawingName) in stateNameDict {
            if let drawing = BFWStyleKit.drawing(forStyleKitName: styleKit, drawingName: drawingName) {
                let icon = DrawingView(frame: drawing.intrinsicFrame)
                icon.drawing = drawing
                icon.tintColor = tintColor
                icon.contentMode = .redraw
                setIconDrawView(icon, for: UIControlState(rawValue: stateNumber.uintValue))
            }
        }
    }
    
    func makeBackgroundDrawViews(from stateNameDict: [NSNumber: String], styleKit: String) {
        backgroundDrawViewForStateDict.removeAll()
        for (stateNumber, drawingName) in stateNameDict {
            let background = DrawingView(frame: self.bounds)
            background.name = drawingName
            background.styleKit = styleKit
            background.contentMode = .redraw
            setBackgroundDrawView(background,
                for: UIControlState(rawValue: stateNumber.uintValue))
        }
    }


    // MARK: - UpdateView
    
    private func setNeedsUpdateView() {
        needsUpdateView = true
        setNeedsLayout()
    }
    
    private var needsUpdateView = true
    
    func updateView() {
        if let iconName = iconName,
            let iconStyleKit = iconStyleKit
        {
            makeIconDrawViews(from: [NSNumber(value: UIControlState.normal.rawValue): iconName],
                              styleKit: iconStyleKit)
        }
    }
    
    private func updateViewIfNeeded() {
        if needsUpdateView {
            needsUpdateView = false
            updateView()
        }
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        updateBackgroundsIfNeeded()
        updateViewIfNeeded()
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
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
