//
//  DrawNibContainerButton.swift
//
//  Created by Tom Brodhurst-Hill on 3/03/2016.
//  Copyright © 2016 BareFeetWare.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit
import BFWControls
import BFWDrawView

@available(*, deprecated, message: "Use DrawNibButton instead.")
open class DrawNibContainerButton: NibContainerButton {

    // MARK: - Variables
    
    private var cellView: DrawNibCellView? {
        return nibView as? DrawNibCellView
    }
    
    @IBInspectable open var iconStyleKit: String? {
        get {
            return iconView?.styleKit
        }
        set {
            iconView?.styleKit = newValue
        }
    }
    
    @IBInspectable open var iconName: String? {
        get {
            return iconView?.name
        }
        set {
            iconView?.name = newValue
        }
    }
    
    open var iconView: DrawingView? {
        get {
            return cellView?.iconDrawView
        }
        set {
            cellView?.iconView = newValue
        }
    }
    
}
