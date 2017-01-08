//
//  DrawingView.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/04/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.

import UIKit

/// DrawingView is a Swift class that will eventually replace BFWDrawView
@IBDesignable class DrawingView: UIView {

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        contentMode = .redraw  // forces redraw when view is resized, eg when device is rotated
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Variables
    
    var drawing: BFWStyleKitDrawing?
    @IBInspectable var name: String? { didSet { updateDrawing() }}
    @IBInspectable var styleKit: String? { didSet { updateDrawing() }}
    
    var styleKitClass: AnyClass? {
        return drawing?.styleKit.paintCodeClass
    }
    
    // MARK: - Private variables

    fileprivate static var moduleName: String? {
        let moduleName: String?
        let components = NSStringFromClass(self).components(separatedBy: ".")
        if components.count == 2 {
            moduleName = components.first
        } else {
            moduleName = nil
        }
        return moduleName
    }
    
    fileprivate var moduleStyleKitName: String? {
        let moduleClassName: String?
        if let styleKit = styleKit,
            let moduleName = type(of: self).moduleName,
            !styleKit.hasPrefix(moduleName)
        {
            moduleClassName = [moduleName, styleKit].joined(separator: ".")
        } else {
            moduleClassName = styleKit
        }
        return moduleClassName
    }
    
    // MARK: - Frame calculations
    
    var drawnSize: CGSize {
        return drawInFrameSize
    }
    
    var drawInFrameSize: CGSize {
        return (drawing?.hasDrawnSize ?? false) ? drawing!.drawnSize : frame.size
    }
    
    var drawFrame: CGRect {
        let drawFrame: CGRect
        switch contentMode {
        case .scaleAspectFit, .scaleAspectFill:
            let widthScale = frame.size.width / drawInFrameSize.width
            let heightScale = frame.size.height / drawInFrameSize.height
            let scale: CGFloat
            if contentMode == .scaleAspectFit {
                scale = widthScale > heightScale ? heightScale : widthScale
            } else {
                scale = widthScale > heightScale ? widthScale : heightScale
            }
            let width = drawInFrameSize.width * scale
            let height = drawInFrameSize.height * scale
            drawFrame = CGRect(x: (frame.size.width - width) / 2.0,
                               y: (frame.size.height - height) / 2.0,
                               width: width,
                               height: height)
        case .scaleToFill, .redraw:
            drawFrame = bounds
        default:
            let x: CGFloat
            let y: CGFloat
            switch contentMode {
            case .topLeft, .bottomLeft, .left:
                x = 0.0
            case .topRight, .bottomRight, .right:
                x = bounds.size.width - drawInFrameSize.width
            case .center, .top, .bottom:
                x = (frame.size.width - drawInFrameSize.width) / 2
            default: // Should never happen.
                x = 0.0
            }
            switch contentMode {
            case .topLeft, .topRight, .top:
                y = 0.0
            case .bottomLeft, .bottomRight, .bottom:
                y = bounds.size.height - drawInFrameSize.height
            case .center, .left, .right:
                y = (frame.size.height - drawInFrameSize.height) / 2
            default: // Should never happen.
                y = 0.0
            }
            drawFrame = CGRect(origin: CGPoint(x: x, y: y), size: drawInFrameSize)
        }
        return drawFrame
    }
    
    // MARK: - Functions
    
    fileprivate func updateDrawing() {
        // TODO: Call this only once for each stylekit and drawing name pair change.
        drawing = BFWStyleKit.drawing(forStyleKitName: moduleStyleKitName,
                                      drawingName: name)
    }
    
    func setNeedsDraw() {
        setNeedsDisplay()
    }
    
    // MARK: - Image rendering
    
    static var imageCache = [String: UIImage]()
    
    fileprivate  var cacheKey: String {
        let components: [String] = [drawing!.name, drawing!.styleKit.name, NSStringFromCGSize(frame.size), tintColor.description]
        let key = components.joined(separator:".")
        return key
    }
    
    fileprivate func cachedImage(for key: String) -> UIImage? {
        return type(of: self).imageCache[key]
    }
    
    fileprivate func cache(image: UIImage, for key: String) {
        type(of: self).imageCache[key] = image
    }
    
    var imageFromView: UIImage? {
        var image: UIImage?
        if drawing != nil {
            if let cachedImage = cachedImage(for: cacheKey) {
                image = cachedImage
            } else if let cachedImage = UIImage(of: self, size: bounds.size) {
                image = cachedImage
                cache(image: cachedImage, for: cacheKey)
            }
        }
        return image
    }
    
    var image: UIImage? {
        return imageFromView
    }
    
    func writeImage(at scale: CGFloat,
                    isOpaque: Bool,
                    to file: URL) -> Bool
    {
        var success = true
        let directory = file.deletingLastPathComponent()
        let directoryPath = directory.path
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                success = false
            }
        }
        if success, let image = image(at: scale, isOpaque: isOpaque) {
            do {
                try UIImagePNGRepresentation(image)?.write(to: file, options: Data.WritingOptions.atomic)
            } catch {
                success = false
            }
        }
        return success
    }
    
    func image(at scale: CGFloat, isOpaque: Bool) -> UIImage? {
        let image: UIImage?
        if canDraw {
            let savedContentsScale = contentScaleFactor
            contentScaleFactor = scale
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, scale)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            contentScaleFactor = savedContentsScale
        } else {
            image = nil
        }
        return image
    }
    
    // MARK: - UIView
    
    override var intrinsicContentSize: CGSize {
        let size: CGSize
        if let drawing = drawing, drawing.hasDrawnSize {
            size = drawing.drawnSize
        } else {
            size = CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
        }
        return size
    }
    
    override var tintColor: UIColor! {
        didSet {
            setNeedsDraw()
        }
    }
    
    override func layoutSubviews() {
        // layoutSubviews is called when constraints change. Since new constraints might resize this view, we need to redraw.
        // TODO: only redraw if size actually changed
        setNeedsDraw()
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        let _ = draw(parameters: parameters)
    }
    
}

// Introspection
extension DrawingView {
    
    var parameters: [String] {
        return drawing?.methodParameters as? [String] ?? []
    }
    
    var drawingSelector: Selector? {
        return drawing.map { NSSelectorFromString($0.methodName) }
    }
    
    var parametersFunctionTuple: [(parameters: [String], function: Any)] {
        // TODO: Cache. Make use of it?
        guard let drawingSelector = drawingSelector,
            let styleKitClass = styleKitClass else
        {
            return []
        }
        return [
            ([], { self.drawFunction(from: styleKitClass, selector: drawingSelector) }),
            (["frame"], { self.drawRectFunction(from: styleKitClass, selector: drawingSelector)!(self.drawFrame) }),
            (["frame", "tintColor"], { self.drawRectColorFunction(from: styleKitClass, selector: drawingSelector)!(self.drawFrame, self.tintColor) })
        ]
    }
    
    var handledParametersArray: [[String]] {
        return [[], ["frame"], ["frame", "tintColor"]]
    }

    var canDraw: Bool {
        return handledParametersArray.contains(where: { (parameters) -> Bool in
            parameters == self.parameters
        })
    }
    
    func draw(parameters: [String]) -> Bool {
        var success = false
        if let drawingSelector = drawingSelector,
            let styleKitClass = styleKitClass
        {
            success = true
            if parameters == [] {
                if let drawFunction = drawFunction(from: styleKitClass, selector: drawingSelector) {
                    drawFunction()
                }
            } else if parameters == ["frame"] {
                if let drawFunction = drawRectFunction(from: styleKitClass, selector: drawingSelector) {
                    drawFunction(drawFrame)
                }
            } else if parameters == ["frame", "tintColor"] {
                if let drawFunction = drawRectColorFunction(from: styleKitClass, selector: drawingSelector) {
                    drawFunction(drawFrame, tintColor)
                }
            } else {
                debugPrint("**** error: Failed to find a drawing for " + NSStringFromSelector(drawingSelector)
                    + " with parameters [" + parameters.joined(separator: ", ") + "]")
                success = false
            }
        }
        return success
    }
    
    func implementation(for owner: AnyObject, selector: Selector) -> IMP {
        let method: Method
        if owner is AnyClass {
            method = class_getClassMethod(owner as! AnyClass, selector)
        } else {
            method = class_getInstanceMethod(type(of: owner), selector)
        }
        return method_getImplementation(method)
    }
    
    func imageFunction(from owner: AnyObject, selector: Selector) -> ((Bool) -> UIImage)? {
        typealias CFunction = @convention(c) (AnyObject, Selector, Bool) -> Unmanaged<UIImage>
        let implementation = self.implementation(for: owner, selector: selector)
        let cFunction = unsafeBitCast(implementation, to: CFunction.self)
        return { bool in
            cFunction(owner, selector, bool).takeUnretainedValue()
        }
    }
    
    func drawFunction(from owner: AnyObject, selector: Selector) -> (() -> Void)? {
        typealias CFunction = @convention(c) (AnyObject, Selector) -> Void
        let implementation = self.implementation(for: owner, selector: selector)
        let cFunction = unsafeBitCast(implementation, to: CFunction.self)
        return {
            cFunction(owner, selector)
        }
    }
    
    func drawRectFunction(from owner: AnyObject, selector: Selector) -> ((CGRect) -> Void)? {
        typealias CFunction = @convention(c) (AnyObject, Selector, CGRect) -> Void
        let implementation = self.implementation(for: owner, selector: selector)
        let cFunction = unsafeBitCast(implementation, to: CFunction.self)
        return { rect in
            cFunction(owner, selector, rect)
        }
    }

    func drawRectColorFunction(from owner: AnyObject, selector: Selector) -> ((CGRect, UIColor) -> Void)? {
        typealias CFunction = @convention(c) (AnyObject, Selector, CGRect, UIColor) -> Void
        let implementation = self.implementation(for: owner, selector: selector)
        let cFunction = unsafeBitCast(implementation, to: CFunction.self)
        return { rect, tintColor in
            cFunction(owner, selector, rect, tintColor)
        }
    }

}
