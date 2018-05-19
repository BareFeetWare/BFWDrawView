//
//  DrawingExport.swift
//
//  Created by Tom Brodhurst-Hill on 23/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

fileprivate extension String {
    
    var androidFileName: String {
        let replacePrefixDict = [
            "button": "btn",
            "icon": "ic"
        ]
        let words = self.wordsFromCamelCase.components(separatedBy: " ")
        let fileNameWords: [String]
        if let firstWord = words.first,
            let replacementWord = replacePrefixDict[firstWord.lowercased()]
        {
            var mutableWords = words
            mutableWords[0] = replacementWord
            fileNameWords = mutableWords
        } else {
            fileNameWords = words
        }
        let fileName = fileNameWords.joined(separator: "_").lowercased()
        return fileName
    }
    
}

class DrawingExport {
    
    typealias PathScale = [String: CGFloat]
    
    enum Key: String {
        case base, size, isOpaque, tintColor, derived, exportBlacklist, animation, array, arrays, scales
    }
    
    
    class func drawingView(name drawingName: String,
                           styleKit: String,
                           tintColor: UIColor) -> DrawingView?
    {
        var drawingView: DrawingView?
        if let drawing = StyleKit.drawing(forStyleKitName: styleKit,
                                          drawingName: drawingName)
        {
            if let frame = drawing.intrinsicFrame {
                if drawing.methodParameters.contains("animation")
                {
                    drawingView = AnimationView(frame: frame)
                } else {
                    drawingView = DrawingView(frame: frame)
                }
                drawingView?.drawing = drawing
                drawingView?.contentMode = .scaleAspectFit
                drawingView?.tintColor = tintColor
            } else {
                debugPrint("missing size for drawing: " + drawingName)
            }
        }
        return drawingView
    }
    
    class func modify(drawingView: DrawingView,
                      with derivedDict: [String: Any])
    {
        // TODO: allow for "Tint Color" & "tintColor"
        if let tintColorString = derivedDict[Key.tintColor.rawValue] as? String,
            let styleKit = drawingView.drawing?.styleKit
        {
            drawingView.tintColor = styleKit.color(for: tintColorString)
        }
        if let sizeString = derivedDict[Key.size.rawValue] as? String {
            let size = CGSizeFromString(sizeString)
            if size != .zero {
                drawingView.frame = CGRect(origin: .zero, size: size)
            }
        }
        if let animation = derivedDict[Key.animation.rawValue] as? Double,
            let animationView = drawingView as? AnimationView
        {
            animationView.animation = animation
            animationView.isPaused = true // so it only creates one image
        }
    }
    
    class func writeAllImages(to directory: URL,
                              styleKitNames: [String],
                              pathScaleDict: PathScale,
                              tintColor: UIColor,
                              isAndroid: Bool,
                              duration: TimeInterval,
                              framesPerSecond: Double)
    {
        var excludeFileNames = Set<String>()
        for styleKitName in styleKitNames {
            if let styleKit = StyleKit.styleKit(for: styleKitName) {
                if let blacklist = styleKit.parameterDict[Key.exportBlacklist.rawValue] as? [String] {
                    for fileName in blacklist {
                        excludeFileNames.insert(fileName.lowercasedWords)
                    }
                }
                for drawingName in styleKit.drawingNames {
                    if let drawing = styleKit.drawing(for: drawingName),
                        drawing.methodParameters.contains("frame"),
                        let drawingView = self.drawingView(name: drawing.name,
                                                           styleKit: styleKitName,
                                                           tintColor: tintColor)
                    {
                        writeImages(from: drawingView,
                                    to: directory,
                                    pathScaleDict: pathScaleDict,
                                    isOpaque: false,
                                    fileName: drawing.name,
                                    isAndroid: isAndroid,
                                    duration: duration,
                                    framesPerSecond: framesPerSecond,
                                    excludeFileNames: &excludeFileNames)
                    }
                }
                if let derivedDictForDrawingName = styleKit.parameterDict[Key.derived.rawValue] as? [String: [String: Any]] {
                    for (drawingName, derivedDict) in derivedDictForDrawingName {
                        if let baseName = derivedDict[Key.base.rawValue] as? String,
                            let drawingView = self.drawingView(name: baseName,
                                                               styleKit: styleKitName,
                                                               tintColor: tintColor)
                        {
                            let isOpaque = derivedDict[Key.isOpaque.rawValue] as? Bool ?? false
                            if drawingName.contains("%@") {
                                if let arrayName = derivedDict[Key.array.rawValue] as? String,
                                    let arrayDict = styleKit.parameterDict[Key.arrays.rawValue] as? [String: [String]],
                                    let array = arrayDict[arrayName]
                                {
                                    for itemString in array {
                                        let itemDrawingName = String(format: drawingName, itemString)
                                        var mutableDerivedDict = derivedDict
                                        for (key, value) in derivedDict {
                                            if Key(rawValue: key) == Key.array {
                                                mutableDerivedDict.removeValue(forKey: key)
                                            } else if let format = value as? String,
                                                format.contains("%@")
                                            {
                                                mutableDerivedDict[key] = String(format: format, itemString)
                                            }
                                        }
                                        modify(drawingView: drawingView,
                                               with: mutableDerivedDict)
                                        writeImages(from: drawingView,
                                                    to: directory,
                                                    pathScaleDict: pathScaleDict,
                                                    isOpaque: isOpaque,
                                                    fileName: itemDrawingName,
                                                    isAndroid: isAndroid,
                                                    duration: duration,
                                                    framesPerSecond: framesPerSecond,
                                                    excludeFileNames: &excludeFileNames)
                                    }
                                }
                            } else {
                                modify(drawingView: drawingView,
                                       with: derivedDict)
                                let usePathScaleDict: PathScale
                                if let scales = derivedDict[Key.scales.rawValue] as? [CGFloat],
                                    !scales.isEmpty
                                {
                                    var dictionary = PathScale()
                                    for (path, scale) in pathScaleDict {
                                        for allowedScale in scales {
                                            if allowedScale == scale {
                                                dictionary[path] = scale
                                                break
                                            }
                                        }
                                    }
                                    usePathScaleDict = dictionary
                                } else {
                                    usePathScaleDict = pathScaleDict
                                }
                                writeImages(from: drawingView,
                                            to: directory,
                                            pathScaleDict: usePathScaleDict,
                                            isOpaque: isOpaque,
                                            fileName: drawingName,
                                            isAndroid: isAndroid,
                                            duration: duration,
                                            framesPerSecond: framesPerSecond,
                                            excludeFileNames: &excludeFileNames)
                            }
                        }
                    }
                }
            }
        }
    }
    
    class func writeImages(from drawingView: DrawingView,
                           to directory: URL,
                           pathScaleDict: PathScale,
                           isOpaque: Bool,
                           fileName: String,
                           isAndroid: Bool,
                           duration: TimeInterval,
                           framesPerSecond: Double,
                           excludeFileNames: inout Set<String>)
    {
        var excludeFileNames = excludeFileNames
        let fileNameLowercaseWords = fileName.lowercasedWords
        if excludeFileNames.contains(fileNameLowercaseWords) {
            debugPrint("skipping excluded or existing file: " + fileNameLowercaseWords)
            return
        }
        let useFileName = isAndroid ? fileName.androidFileName : fileName
        for (path, scale) in pathScaleDict {
            let baseFileUrl: URL
            if path.contains("%@") {
                let component = String(format: path, useFileName)
                baseFileUrl = directory.appendingPathComponent(component)
            } else {
                baseFileUrl = directory.appendingPathComponent(path).appendingPathComponent(useFileName)
            }
            let fileUrl = baseFileUrl.appendingPathExtension("png")
            let success : Bool
            if let animationView = drawingView as? AnimationView {
                if duration > 0 {
                    animationView.duration = duration
                    animationView.framesPerSecond = framesPerSecond
                    success = animationView.writeImages(at: scale,
                                                        isOpaque: isOpaque,
                                                        to: fileUrl)
                } else {
                    // Skip because duration = 0 means no export of the animation.
                    success = true
                }
            } else {
                success = drawingView.writeImage(at: scale,
                                                 isOpaque: isOpaque,
                                                 to: fileUrl)
            }
            if success {
                excludeFileNames.insert(fileNameLowercaseWords)
            } else {
                debugPrint("failed to write " + fileUrl.path)
            }
        }
    }
    
    class func export(isAndroid: Bool,
                      to directory: URL,
                      deleteExistingFiles: Bool,
                      drawingsStyleKitNames: [String],
                      colorsStyleKitNames: [String],
                      pathScaleDict: PathScale,
                      tintColor: UIColor,
                      duration: TimeInterval,
                      framesPerSecond: Double)
    {
        let fileManager = FileManager.default
        if let existingUrls = try? fileManager.contentsOfDirectory(at: directory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        {
            debugPrint("Deleting \(existingUrls.count) existing files from \(directory)")
            for file in existingUrls {
                try? fileManager.removeItem(at: file)
            }
        }
        debugPrint("writing images to " + directory.path)
        writeAllImages(to: directory,
                       styleKitNames: drawingsStyleKitNames,
                       pathScaleDict: pathScaleDict,
                       tintColor: tintColor,
                       isAndroid: isAndroid,
                       duration: duration,
                       framesPerSecond: framesPerSecond)
        if isAndroid {
            let styleKits = colorsStyleKitNames.compactMap { styleKitName in
                return StyleKit.styleKit(for: styleKitName)
            }
            let colorsXmlString = colorsXml(for: styleKits)
            let colorsDirectory = directory.appendingPathComponent("values", isDirectory: true)
            let colorsFile = colorsDirectory.appendingPathComponent("colors.xml")
            if !FileManager.default.fileExists(atPath: colorsDirectory.path) {
                try? FileManager.default.createDirectory(at: colorsDirectory,
                                                         withIntermediateDirectories: true,
                                                         attributes: nil)
            }
            try? colorsXmlString.write(to: colorsFile,
                                       atomically: true,
                                       encoding: String.Encoding.ascii)
        }
    }
    
    class var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first!
    }
    
    class func colorsXml(for styleKits: [StyleKit]) -> String {
        var colorsDict = [String: UIColor]()
        for styleKit in styleKits {
            for colorName in styleKit.colorNames {
                var shouldAdd = true
                let addingColor = styleKit.color(for: colorName)!
                if let existingColor = colorsDict[colorName] {
                    if existingColor != addingColor {
                        shouldAdd = false
                        debugPrint("Skipping color \"\(colorName)\"") // = #\(addingColor.hexString), from styleKit \"\(styleKit.name)\", which would overwrite existing #\(existingColor.hexString)")
                    }
                }
                if shouldAdd {
                    colorsDict[colorName] = addingColor
                }
            }
        }
        var components = [String]()
        for colorName in colorsDict.keys {
            let color = colorsDict[colorName]!
            let colorHex = color.hexString
            let wordsString = colorName.wordsFromCamelCase
            let underscoreName = wordsString.replacingOccurrences(of: " ", with: "_")
            let androidColorName = underscoreName.lowercased()
            let colorString = "    <color name=\"" + androidColorName + "\">#" + colorHex + "</color>"
            components += [colorString]
        }
        components.sort()
        components.insert("<!--Warning: Do not add any color to this file as it is generated by PaintCode and BFWDrawView-->", at: 0)
        components.insert("<resources>", at: 1)
        components += ["</resources>"]
        let colorsXmlString = components.joined(separator: "\n")
        return colorsXmlString
    }
    
}
