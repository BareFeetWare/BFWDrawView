//
//  SampleDrawingButton.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 13/05/2015.
//  Copyright (c) 2015 BareFeetWare.
//

import UIKit

@IBDesignable class SampleDrawingButton: DrawingButton {
    
    override func commonInit() {
        super.commonInit()
        makeBackgroundDrawViews(from: [UIControlState.normal.rawValue: "Button",
                                       UIControlState.highlighted.rawValue: "Button Highlighted"],
                                styleKit: "SampleStyleKit")
        setShadow(SampleStyleKit.buttonShadow(),
                  for:.normal)
        setShadow(SampleStyleKit.buttonShadowHighlighted(),
                  for:.highlighted)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 80.0, height: 44.0)
    }
    
}
