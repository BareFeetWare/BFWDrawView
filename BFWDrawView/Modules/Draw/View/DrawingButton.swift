//
//  DrawingButton.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 9/07/2016.
//  Copyright (c) 2016 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

@IBDesignable class DrawingButton: BFWDrawButton {

    // MARK: - Variables

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
            let icon = BFWDrawView(frame: frame)
            icon.drawing = drawing
            icon.tintColor = tintColor
            icon.contentMode = .redraw
            setIconDrawView(icon, for: state)
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
            makeIconDrawViews(fromStateNameDict: [UIControlState.normal.rawValue: iconName],
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
        updateViewIfNeeded()
        super.layoutSubviews()
    }

}
