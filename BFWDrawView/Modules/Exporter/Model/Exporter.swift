//
//  Exporter.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 1/02/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import Foundation

class Exporter {

    // MARK: - Public variables

    var root: ExportersRoot!
    var name: String!
    var isAndroid: Bool?
    var resolutions: DrawingExport.PathScale?
    var exportDirectoryURL: URL?
    var drawingsStyleKitNames: [String]?
    var colorsStyleKitNames: [String]?
    var includeAnimations: Bool?
    var duration: TimeInterval?
    var framesPerSecond: CGFloat?

    // MARK: - Public read only variables
    
    var defaultDirectoryURL: URL {
        return documentsURL.appendingPathComponent("android_drawables", isDirectory: true)
    }
    
    var defaultResolutions: DrawingExport.PathScale {
        var resolutions: DrawingExport.PathScale
        if isAndroid ?? true {
            resolutions = [
                "drawable-ldpi": 0.75,
                "drawable-mdpi": 1.0,
                "drawable-hdpi": 1.5,
                "drawable-xhdpi": 2.0,
                "drawable-xxhdpi": 3.0,
                "drawable-xxxhdpi": 4.0
            ]
        } else {
            resolutions = [
                "@1x": 1.0,
                "@2x": 2.0,
                "@3x": 3.0
            ]
        }
        // TODO: Move the resolution lists to something configurable, such as a plist.
        return resolutions
    }
    
    // MARK: - Structs
    
    fileprivate struct DefaultsKey {
        static let name = "name"
        static let isAndroid = "isAndroid"
        static let resolutions = "resolutions"
        static let pathScaleDict = "pathScaleDict"
        static let exportDirectoryURL = "exportDirectoryURL"
        static let drawingsStyleKitNames = "drawingsStyleKitNames"
        static let colorsStyleKitNames = "colorsStyleKitNames"
        static let includeAnimations = "includeAnimations"
        static let duration = "duration"
        static let framesPerSecond = "framesPerSecond"
    }
    
    // MARK: - Init
    
    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        self.name = dictionary[DefaultsKey.name] as? String
        self.isAndroid = dictionary[DefaultsKey.isAndroid] as? Bool
        self.resolutions = dictionary[DefaultsKey.resolutions] as? DrawingExport.PathScale
        if let exportDirectoryURLString = dictionary[DefaultsKey.exportDirectoryURL] as? String {
            self.exportDirectoryURL = URL(string: exportDirectoryURLString)
        }
        self.drawingsStyleKitNames = dictionary[DefaultsKey.drawingsStyleKitNames] as? [String]
        self.colorsStyleKitNames = dictionary[DefaultsKey.colorsStyleKitNames] as? [String]
        self.includeAnimations = dictionary[DefaultsKey.includeAnimations] as? Bool
        self.duration = dictionary[DefaultsKey.duration] as? TimeInterval
        self.framesPerSecond = dictionary[DefaultsKey.framesPerSecond] as? CGFloat
    }
    
    // MARK: - Dictionary for archiving
    
    var dictionary: [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary[DefaultsKey.name] = self.name as AnyObject?
        dictionary[DefaultsKey.isAndroid] = self.isAndroid as AnyObject?
        dictionary[DefaultsKey.resolutions] = self.resolutions as AnyObject?
        dictionary[DefaultsKey.exportDirectoryURL] = self.exportDirectoryURL?.absoluteString as AnyObject?
        dictionary[DefaultsKey.drawingsStyleKitNames] = self.drawingsStyleKitNames as AnyObject?
        dictionary[DefaultsKey.colorsStyleKitNames] = self.colorsStyleKitNames as AnyObject?
        dictionary[DefaultsKey.includeAnimations] = self.includeAnimations as AnyObject?
        dictionary[DefaultsKey.duration] = self.duration as AnyObject?
        dictionary[DefaultsKey.framesPerSecond] = self.framesPerSecond as AnyObject?
        return dictionary
    }
    
    // MARK: - Private variables
    
    fileprivate var pathScaleDict: DrawingExport.PathScale {
        let resolutions = self.resolutions ?? defaultResolutions
        var pathScaleDict = resolutions
        let isIos = !(isAndroid ?? true)
        if isIos {
            pathScaleDict = DrawingExport.PathScale()
            for (path, scale) in resolutions {
                // Only append @2x or @3x, but no suffix for @1x since xcassets doesn't want it.
                let format = "%@" + (scale == 1.0 ? "" : path)
                pathScaleDict[format] = scale
            }
        }
        return pathScaleDict
    }
    
    fileprivate var documentsURL: URL {
        return DrawingExport.documentsDirectory
    }
    
    // MARK - Actions
    
    func export() {
        DrawingExport.export(
            isAndroid: isAndroid ?? true,
            to: exportDirectoryURL ?? defaultDirectoryURL,
            deleteExistingFiles: true,
            drawingsStyleKitNames: drawingsStyleKitNames ?? BFWStyleKit.styleKitNames() as! [String],
            colorsStyleKitNames: colorsStyleKitNames ?? BFWStyleKit.styleKitNames() as! [String],
            pathScaleDict: pathScaleDict,
            tintColor: UIColor.black, // TODO: get color from UI
            duration: duration ?? 0.0,
            framesPerSecond: framesPerSecond ?? 0.0
        )
    }

}
