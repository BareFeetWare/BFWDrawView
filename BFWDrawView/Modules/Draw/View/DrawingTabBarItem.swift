//
//  DrawingTabBarItem.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 5/7/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

@IBDesignable open class DrawingTabBarItem: UITabBarItem, Drawable {
    
    @IBInspectable open var drawingName: String? { didSet { updateDrawing() }}
    @IBInspectable open var styleKit: String? { didSet { updateDrawing() }}
    
    open var drawing: Drawing?
    open var defaultSize = CGSize(width: 32, height: 32)
    
}
