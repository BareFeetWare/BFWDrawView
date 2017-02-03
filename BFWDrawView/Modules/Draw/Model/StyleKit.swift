//
//  StyleKit.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import Foundation

class StyleKit: NSObject {

    // MARK: - Stored variables
    
    var name: String!
    
    // MARK: - Init
    
    init(name: String) {
        self.name = name
    }
    
    // MARK: - Computed variables

    var paintCodeClass: AnyClass? { // class exported by PaintCode
        guard let moduleStyleKitName = moduleStyleKitName
            else { return nil }
        return NSClassFromString(moduleStyleKitName)
    }

    lazy var classMethodNames: [String]? = {
        return self.paintCodeClass?.classMethodNames() as? [String]
    }()
    
    var moduleStyleKitName: String? {
        let moduleStyleKitName: String?
        if let name = name,
            let moduleName = type(of: self).moduleName
        {
            moduleStyleKitName = [moduleName, name].joined(separator: ".")
        } else {
            moduleStyleKitName = name
        }
        return moduleStyleKitName
    }
    
    // MARK: - Constants
    
    struct FileNameSuffix {
        static let styleKit = "StyleKit"
    }
    
    enum Key: String {
        case styleKitByPrefix
    }
    
    // MARK: - Class variables & functions
    
    static var styleKitForNameDict = [String: StyleKit]()
    
    static var styleKitNames: [String] = {
        var styleKitNames = [String]()
        for aClass in (NSObject.subclasses(of: NSObject.self) as! [AnyClass]) {
            let className = NSStringFromClass(aClass)
            if className.hasSuffix(FileNameSuffix.styleKit),
                className != NSStringFromClass(StyleKit.self)
            {
                // TODO: implement a more robust filter than suffix when PaintCode offers it
                styleKitNames += [className]
            }
        }
        return styleKitNames
    }()


    static func styleKit(for name: String) -> StyleKit? {
        var styleKit: StyleKit? = nil
        // Remove the <ModuleName>. prefix that Swift adds:
        if let className = name.components(separatedBy: ".").last {
            if let existingStyleKit = styleKitForNameDict[className] {
                styleKit = existingStyleKit
            } else {
                styleKit = StyleKit(name: className)
                styleKitForNameDict[className] = styleKit
            }
        }
        return styleKit
    }

    static func drawing(forStyleKitName styleKitName: String,
                        drawingName: String) -> Drawing?
    {
        return styleKit(for: styleKitName)?.drawing(for: drawingName)
    }
    
    // TODO: Move moduleName to extension on NSObject?
    
    static var moduleName: String? {
        let moduleName: String?
        let components = NSStringFromClass(self).components(separatedBy: ".")
        if components.count == 2 {
            moduleName = components.first
        } else {
            moduleName = nil
        }
        return moduleName
    }
    
    // MARK: - Full list functions
    
    // Calling any of these methods is expensive, since it executes every method and caches the returnValue. Use only for discovery, eg showing a browser of all drawings.
    
    lazy var returnValueForClassMethodNameDict: [String: Any]? = {
        debugPrint("**** warning: calling returnValueForClassMethodNameDict for BFWStyleKit name [\(self.name ?? "nil")], which has a large up front caching hit for the app. Only call this if you want to browse the entire list of drawings and colors available from the styleKit")
        return self.paintCodeClass?.returnValueForClassMethodNameDict() as? [String: Any]
    }()
    
    fileprivate lazy var colorsDict: [String: UIColor] = {
        var colorsDict = [String: UIColor]()
        if let methodValueDict = self.returnValueForClassMethodNameDict {
            for (methodName, returnValue) in methodValueDict {
                if let color = returnValue as? UIColor {
                    // TODO: filter out non color methods
                    colorsDict[methodName] = color
                }
            }
        }
        return colorsDict
    }()
    
    lazy var colorNames: [String] = {
        return Array(self.colorsDict.keys)
    }()
    
    lazy var drawingNames: [String] = {
        var drawingNames = [String]()
        if let methodValueDict = self.returnValueForClassMethodNameDict {
            for (methodName, returnValue) in methodValueDict {
                if returnValue is NSNull && methodName.hasPrefix(Drawing.FileName.drawPrefix),
                    let drawingName = self.drawingName(forMethodName: methodName)
                {
                    drawingNames += [drawingName]
                }
            }
        }
        return drawingNames
    }()

    // MARK: - Use cache if already created.

    func returnValue(forClassMethodName methodName: String) -> Any? {
        let returnValue: Any?
        if let returnValueForClassMethodNameDict = self.returnValueForClassMethodNameDict {
            returnValue = returnValueForClassMethodNameDict[methodName]
        } else {
            returnValue = self.paintCodeClass?.returnValue(forClassMethodName: methodName)
        }
        return returnValue
    }

    // MARK: - Plist

    var bundle: Bundle {
        #if TARGET_INTERFACE_BUILDER // rendering in storyboard using IBDesignable
            let bundle = Bundle.bundleForClass(Self)
        #else
            let bundle = Bundle.main
        #endif
        return bundle
    }

    lazy var parameterDict: [String: Any] = {
        guard let path = self.bundle.path(forResource: self.name, ofType: "plist"),
            var parameterDict = NSDictionary(contentsOfFile: path) as? [String: [String: Any]]
            else { return [:] }
        //TODO: move filtering to another class with references to consts for keys
        for key in ["sizes", "sizesByPrefix", "derived"] {
            if let dictionary = parameterDict[key] {
                var mutableDict = [String: Any]()
                for (oldKey, value) in dictionary {
                    let newKey = oldKey.lowercaseWords
                    mutableDict[newKey] = value
                }
                parameterDict[key] = mutableDict
            }
        }
        return parameterDict
    }()

    // MARK: - Colors

    var colorForNameDict = [String: UIColor]()

    func color(for colorName: String) -> UIColor? {
        let color: UIColor?
        if let existingColor = (colorForNameDict as NSDictionary).object(forWordsKey: colorName) as? UIColor {
            color = existingColor
        } else if let classMethodNames = classMethodNames {
            let methodName = colorName.words(matchingWordsArray: classMethodNames)
            if let existingColor = returnValue(forClassMethodName: methodName) as? UIColor {
                // TODO: filter out non color methods
                color = existingColor
                colorForNameDict[methodName] = color
            } else {
                color = nil
                debugPrint("**** error: failed to find color for name: %@", colorName)
            }
        } else {
            color = nil
        }
        return color
    }

    // MARK: - Drawings

    var drawingForNameDict = [String: Drawing]()
    
    func drawingName(forMethodName methodName: String) -> String? {
        return methodName.methodNameComponents?
            .first?.substring(from: Drawing.FileName.drawPrefix.endIndex).lowercaseFirstCharacter
    }
    
    func classMethodName(forDrawingName drawingName: String) -> String? {
        var methodName: String? = nil
        let drawingWords = Drawing.FileName.drawPrefix + " " + drawingName.lowercaseWords
        if let classMethodNames = classMethodNames {
            for searchMethodName in classMethodNames {
                if let baseName = searchMethodName.methodNameComponents?.first,
                    baseName.lowercaseWords == drawingWords
                {
                    methodName = searchMethodName
                    break
                }
            }
        }
        return methodName
    }

    func drawing(for drawingName: String) -> Drawing? {
        let drawing: Drawing?
        if let prefixDict = parameterDict[Key.styleKitByPrefix.rawValue] as? [String: Any],
            let redirectStyleKitName = (prefixDict as NSDictionary)
                .objectForLongestPrefixKeyMatchingWords(in: drawingName) as? String,
            redirectStyleKitName != name
        {
            let styleKit = StyleKit.styleKit(for: redirectStyleKitName)
            drawing = styleKit?.drawing(for: drawingName)
        } else {
            let drawingKey = drawingName.lowercaseWords
            if let dictDrawing = drawingForNameDict[drawingKey] {
                drawing = dictDrawing
            } else if let _ = classMethodName(forDrawingName: drawingName) {
                drawing = Drawing(styleKit: self, name: drawingName)
                drawingForNameDict[drawingKey] = drawing
            } else {
                drawing = nil
                debugPrint("failed to find drawing name: %@", drawingName)
            }
        }
        return drawing
    }

}
