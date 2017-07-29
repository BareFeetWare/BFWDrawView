//
//  DrawingTableViewCell.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 20/7/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

@IBDesignable open class DrawingTableViewCell: UITableViewCell {
    
    @IBInspectable open var iconName: String? { didSet { updateIcon() }}
    @IBInspectable open var iconStyleKit: String? { didSet { updateIcon() }}
    
    open var iconDrawing: Drawing? {
        didSet {
            imageView?.image = UIImage.image(
                drawing: iconDrawing,
                tintColor: imageView?.tintColor
            )
        }
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        updateIcon()
    }
    
    private func updateIcon() {
        guard let iconName = iconName, !iconName.isEmpty,
            let iconStyleKit = iconStyleKit, !iconStyleKit.isEmpty
            else { return }
        iconDrawing = StyleKit.drawing(forStyleKitName: iconStyleKit, drawingName: iconName)
    }
    
}
