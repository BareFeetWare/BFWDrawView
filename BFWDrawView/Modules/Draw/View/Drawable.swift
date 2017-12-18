//
//  Drawable.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 13/7/17.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

internal protocol Drawable: class {
    
    // MARK: - Required
    
    var drawing: Drawing? { get set }
    var image: UIImage? { get set }
    var drawingName: String? { get }
    var styleKit: String? { get }
    
    // MARK: - Optional

    var defaultSize: CGSize? { get }
    
}

internal extension Drawable {
    
    var defaultSize: CGSize? {
        return nil
    }

    func updateDrawing() {
        if let drawingName = drawingName, !drawingName.isEmpty,
            let styleKit = styleKit, !styleKit.isEmpty
        {
            drawing = StyleKit(name: styleKit).drawing(for: drawingName)
        } else {
            drawing = nil
        }
        updateImage()
    }
    
    func updateImage() {
        // TODO: Maybe delay creating the image until image get, so it's not possibly created twice for each change to drawingName and styleKitName.
        image = drawing.flatMap {
            UIImage.image(drawing: $0,
                          size: defaultSize)
        }
    }

}
