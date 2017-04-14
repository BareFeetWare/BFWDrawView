//
//  DrawNibButton.swift
//
//  Created by Tom Brodhurst-Hill on 3/03/2016.
//  Copyright © 2016 BareFeetWare.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit
import BFWControls
import BFWDrawView

open class DrawNibButton: NibButton {

    // MARK: - Variables
    
    // Override in subclass
    open var buttonView: DrawButtonView? {
        return nil
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
            return buttonView?.iconView
        }
        set {
            buttonView?.iconView = newValue
        }
    }
    
    // MARK: - NibButton
    
    open override var contentView: NibView? {
        return buttonView
    }
    
    // MARK: - UIButton
    
    open override var titleLabel: UILabel? {
        return buttonView?.titleLabel
    }

}
