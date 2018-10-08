//
//  DrawingImageView.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 2/5/18.
//  Copyright © 2018 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

open class DrawingImageView: UIImageView {
    
    // MARK: - Variables
    
    open var drawing: Drawing? { didSet { setNeedsUpdateImage() }}
    @IBInspectable open var name: String? { didSet { updateDrawing() }}
    @IBInspectable open var styleKit: String? { didSet { updateDrawing() }}
    
    // MARK: - Update drawing
    
    private func updateDrawing() {
        // TODO: Call this only once for each stylekit and drawing name pair change.
        guard let name = name,
            let styleKitName = styleKit
            else { return }
        drawing = StyleKit.drawing(forStyleKitName: styleKitName,
                                   drawingName: name)
    }
    
    // MARK: - Update image
    
    private var needsUpdateImage = false
    
    private func setNeedsUpdateImage() {
        needsUpdateImage = true
        setNeedsLayout()
    }
    
    private func updateImageIfNeeded() {
        if needsUpdateImage {
            needsUpdateImage = false
            updateImage()
        }
    }
    
    private func updateImage() {
        let drawingView = DrawingView(frame: bounds)
        drawingView.drawing = drawing
        drawingView.contentMode = contentMode
        drawingView.tintColor = tintColor
        image = drawingView.image
    }
    
    // MARK: - UIView
    
    open override var intrinsicContentSize: CGSize {
        return drawing?.drawnSize ?? super.intrinsicContentSize
    }
    
    open override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsUpdateImage()
    }
    
    open override var frame: CGRect {
        didSet {
            if oldValue.size != frame.size {
                setNeedsUpdateImage()
            }
        }
    }
    
    open override var contentMode: UIView.ContentMode {
        didSet {
            if oldValue != contentMode {
                setNeedsUpdateImage()
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateImageIfNeeded()
    }
    
}
