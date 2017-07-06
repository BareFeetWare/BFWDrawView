//
//  UIImage+Drawing.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 6/7/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//

import Foundation

extension UIImage {
    
    class func image(styleKitName: String?,
                     drawingName: String?,
                     size: CGSize? = nil
        ) -> UIImage?
    {
        guard let drawingName = drawingName, !drawingName.isEmpty,
            let styleKitName = styleKitName, !styleKitName.isEmpty,
            let drawing = StyleKit(name: styleKitName).drawing(for: drawingName),
            let size = size ?? drawing.drawnSize
            else { return nil }
        let frame = CGRect(origin: .zero, size: size)
        // TODO: Get image from drawing (for size), without need for DrawingView.
        let drawingView = DrawingView(frame: frame)
        drawingView.drawing = drawing
        return drawingView.image
    }
    
}
