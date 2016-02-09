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
    var resolutions: [String: Double]?
    var exportDirectoryURL: NSURL?
    var drawingsStyleKitNames: [String]?
    var colorsStyleKitNames: [String]?
    var includeAnimations: Bool?
    var duration: NSTimeInterval?
    var framesPerSecond: Double?

    // MARK: - Public read only variables
    
    var defaultDirectoryURL: NSURL {
        return documentsURL.URLByAppendingPathComponent("android_drawables", isDirectory: true)
    }
    
    var defaultResolutions: [String: Double] {
        var resolutions: [String: Double]
        if (isAndroid ?? true) {
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
    
    private struct DefaultsKey {
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
        self.resolutions = dictionary[DefaultsKey.resolutions] as? [String: Double]
        if let exportDirectoryURLString = dictionary[DefaultsKey.exportDirectoryURL] as? String {
            self.exportDirectoryURL = NSURL(string: exportDirectoryURLString)
        }
        self.drawingsStyleKitNames = dictionary[DefaultsKey.drawingsStyleKitNames] as? [String]
        self.colorsStyleKitNames = dictionary[DefaultsKey.colorsStyleKitNames] as? [String]
        self.includeAnimations = dictionary[DefaultsKey.includeAnimations] as? Bool
        self.duration = dictionary[DefaultsKey.duration] as? NSTimeInterval
        self.framesPerSecond = dictionary[DefaultsKey.framesPerSecond] as? Double
    }
    
    // MARK: - Dictionary for archiving
    
    var dictionary: [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary[DefaultsKey.name] = self.name
        dictionary[DefaultsKey.isAndroid] = self.isAndroid
        dictionary[DefaultsKey.resolutions] = self.resolutions
        dictionary[DefaultsKey.exportDirectoryURL] = self.exportDirectoryURL?.absoluteString
        dictionary[DefaultsKey.drawingsStyleKitNames] = self.drawingsStyleKitNames
        dictionary[DefaultsKey.colorsStyleKitNames] = self.colorsStyleKitNames
        dictionary[DefaultsKey.includeAnimations] = self.includeAnimations
        dictionary[DefaultsKey.duration] = self.duration
        dictionary[DefaultsKey.framesPerSecond] = self.framesPerSecond
        return dictionary
    }
    
    // MARK: - Private variables
    
    private var pathScaleDict: [String: Double] {
        let resolutions = self.resolutions ?? defaultResolutions
        var pathScaleDict = resolutions
        let isIos = !(isAndroid ?? true)
        if isIos {
            pathScaleDict = [String: Double]()
            for (path, scale) in resolutions {
                let format = "%@" + path
                pathScaleDict[format] = scale
            }
        }
        return pathScaleDict
    }
    
    private var documentsURL: NSURL {
        return NSURL(fileURLWithPath: BFWDrawExport.documentsDirectoryPath(), isDirectory: true)
    }
    
    // MARK - Actions
    
    func export() {
        BFWDrawExport.exportForAndroid(
            isAndroid ?? true,
            toDirectory: exportDirectoryURL?.path ?? defaultDirectoryURL.path,
            drawingsStyleKitNames: drawingsStyleKitNames ?? BFWStyleKit.styleKitNames(),
            colorsStyleKitNames: colorsStyleKitNames ?? BFWStyleKit.styleKitNames(),
            pathScaleDict: pathScaleDict,
            tintColor: UIColor.blackColor(), // TODO: get color from UI
            duration: duration ?? 0.0,
            framesPerSecond: framesPerSecond ?? 00
        )
    }

}