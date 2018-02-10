//
//  DrawNibTableViewCell.swift
//  BFWDrawNibView
//
//  Created by Tom Brodhurst-Hill on 29/1/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit
import BFWControls
import BFWDrawView

open class DrawNibTableViewCell: NibTableViewCell {

    // MARK - Variables
    
    open var drawingView: DrawingView? {
        return (cellView as? DrawNibCellView)?.iconDrawView
    }

    @IBInspectable open var name: String? {
        get {
            return (cellView as? DrawNibCellView)?.iconDrawView?.name
        }
        set {
            (cellView as? DrawNibCellView)?.iconDrawView?.name = newValue
        }
    }
    
    @IBInspectable open var styleKit: String? {
        get {
            return (cellView as? DrawNibCellView)?.iconDrawView?.styleKit
        }
        set {
            (cellView as? DrawNibCellView)?.iconDrawView?.styleKit = newValue
        }
    }

}
