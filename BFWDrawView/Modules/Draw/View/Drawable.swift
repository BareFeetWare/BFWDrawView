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
