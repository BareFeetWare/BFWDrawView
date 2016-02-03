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
    var pathScaleDict: [String: Double]?
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

    // MARK: - Structs
    
    private struct DefaultsKey {
        static let name = "name"
        static let isAndroid = "isAndroid"
        static let pathScaleDict = "pathScaleDict"
        static let exportDirectoryURL = "exportDirectoryURL"
        static let drawingsStyleKitNames = "drawingsStyleKitNames"
        static let colorsStyleKitNames = "colorsStyleKitNames"
        static let includeAnimations = "includeAnimations"
        static let duration = "duration"
        static let framesPerSecond = "framesPerSecond"
    }
    
    // MARK: - Init
    
    init() {
        
    }
    
    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        self.name = dictionary[DefaultsKey.name] as? String
        self.isAndroid = dictionary[DefaultsKey.isAndroid] as? Bool
        self.pathScaleDict = dictionary[DefaultsKey.pathScaleDict] as? [String: Double]
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
        dictionary[DefaultsKey.pathScaleDict] = self.pathScaleDict
        dictionary[DefaultsKey.exportDirectoryURL] = self.exportDirectoryURL?.absoluteString
        dictionary[DefaultsKey.drawingsStyleKitNames] = self.drawingsStyleKitNames
        dictionary[DefaultsKey.colorsStyleKitNames] = self.colorsStyleKitNames
        dictionary[DefaultsKey.includeAnimations] = self.includeAnimations
        dictionary[DefaultsKey.duration] = self.duration
        dictionary[DefaultsKey.framesPerSecond] = self.framesPerSecond
        return dictionary
    }
    
    // MARK: - Private variables
    
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