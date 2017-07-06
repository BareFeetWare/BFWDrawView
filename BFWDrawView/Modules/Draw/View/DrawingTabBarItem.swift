//
//  DrawingTabBarItem.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 5/7/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

class DrawingTabBarItem: UITabBarItem {
    
    @IBInspectable var drawingName: String? { didSet { updateImage() }}
    @IBInspectable var styleKit: String? { didSet { updateImage() }}
    
    var defaultSize = CGSize(width: 32, height: 32)
    
    private func updateImage() {
        guard let drawingName = drawingName, !drawingName.isEmpty,
            let styleKit = styleKit, !styleKit.isEmpty,
            let drawing = StyleKit(name: styleKit).drawing(for: drawingName)
            else { return }
        let size = drawing.drawnSize ?? defaultSize
        let frame = CGRect(origin: .zero, size: size)
        // TODO: Get image from drawing (for size), without need for DrawingView.
        let drawingView = DrawingView(frame: frame)
        drawingView.drawing = drawing
        // TODO: Maybe delay creating the image until image get, so it's not possibly created twice for each change to drawingName and styleKit.
        image = drawingView.image
    }
    
}
