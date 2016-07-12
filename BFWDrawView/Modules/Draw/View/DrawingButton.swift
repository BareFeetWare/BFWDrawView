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
    
    // MARK: - UpdateView
    
    private func setNeedsUpdateView() {
        needsUpdateView = true
        setNeedsLayout()
    }
    
    private var needsUpdateView = true
    
    func updateView() {
        if let iconName = iconName, iconStyleKit = iconStyleKit {
            makeIconDrawViewsFromStateNameDict([UIControlState.Normal.rawValue: iconName],
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
