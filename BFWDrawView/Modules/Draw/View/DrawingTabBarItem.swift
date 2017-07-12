//
//  DrawingTabBarItem.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 5/7/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

@IBDesignable open class DrawingTabBarItem: UITabBarItem {
    
    @IBInspectable var drawingName: String? { didSet { updateDrawing() }}
    @IBInspectable var styleKit: String? { didSet { updateDrawing() }}
    
    open var defaultSize = CGSize(width: 32, height: 32)
    
    open var drawing: Drawing?
    
    private func updateDrawing() {
        guard let drawingName = drawingName, !drawingName.isEmpty,
            let styleKit = styleKit, !styleKit.isEmpty
            else { return }
        drawing = StyleKit(name: styleKit).drawing(for: drawingName)
        updateImage()
    }
    
    private func updateImage() {
        guard let drawing = drawing
            else { return }
        if let drawingImage = UIImage.image(drawing: drawing,
                                            size: defaultSize)
        {
            // TODO: Maybe delay creating the image until image get, so it's not possibly created twice for each change to drawingName and styleKitName.
            image = drawingImage
        }
    }
    
}
