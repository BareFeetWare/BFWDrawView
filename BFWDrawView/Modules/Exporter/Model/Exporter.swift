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
    var framesPerSecond: Double?

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
    
    convenience init(dictionary: [String: Any]) {
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
        self.framesPerSecond = dictionary[DefaultsKey.framesPerSecond] as? Double
    }
    
    // MARK: - Dictionary for archiving
    
    var dictionary: [String: Any] {
        var dictionary = [String: Any]()
        dictionary[DefaultsKey.name] = name
        dictionary[DefaultsKey.isAndroid] = isAndroid
        dictionary[DefaultsKey.resolutions] = resolutions
        dictionary[DefaultsKey.exportDirectoryURL] = exportDirectoryURL?.absoluteString
        dictionary[DefaultsKey.drawingsStyleKitNames] = drawingsStyleKitNames
        dictionary[DefaultsKey.colorsStyleKitNames] = colorsStyleKitNames
        dictionary[DefaultsKey.includeAnimations] = includeAnimations
        dictionary[DefaultsKey.duration] = duration
        dictionary[DefaultsKey.framesPerSecond] = framesPerSecond
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
            drawingsStyleKitNames: drawingsStyleKitNames ?? StyleKit.styleKitNames,
            colorsStyleKitNames: colorsStyleKitNames ?? StyleKit.styleKitNames,
            pathScaleDict: pathScaleDict,
            tintColor: UIColor.black, // TODO: get color from UI
            duration: includeAnimations ?? false
                ? duration ?? 0.0
                : 0.0,
            framesPerSecond: framesPerSecond ?? 0.0
        )
    }

}
