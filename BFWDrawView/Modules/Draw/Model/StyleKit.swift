//
//  StyleKit.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/07/2015.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import Foundation

open class StyleKit: NSObject {

    // MARK: - Stored variables
    
    open var name: String!
    
    // MARK: - Init
    
    init(name: String) {
        self.name = name
    }
    
    // MARK: - Computed variables

    internal var paintCodeClass: AnyClass? { // class exported by PaintCode
        guard let className = className
            else { return nil }
        return NSClassFromString(className)
    }

    internal lazy var classMethodNames: [String]? = {
        return self.paintCodeClass?.classMethodNames() as? [String]
    }()
    
    fileprivate var className: String? {
        let components = name.components(separatedBy: ".")
        switch components.count {
        case 2:
            return name
        default:
            return StyleKit.styleKitNames.first { styleKitName in
                name == styleKitName.components(separatedBy: ".").last!
            }
        }
    }
    
    // MARK: - Constants
    
    fileprivate struct FileNameSuffix {
        static let styleKit = "StyleKit"
    }
    
    fileprivate enum Key: String {
        case styleKitByPrefix
    }
    
    // MARK: - Class variables & functions
    
    fileprivate static var styleKitForNameDict = [String: StyleKit]()
    
    open static var styleKitNames: [String] = {
        var styleKitNames = [String]()
        for aClass in (NSObject.subclasses(of: NSObject.self) as! [AnyClass]) {
            let className = NSStringFromClass(aClass)
            if className.hasSuffix(FileNameSuffix.styleKit),
                aClass != StyleKit.self
            {
                // TODO: implement a more robust filter than suffix when PaintCode offers it
                styleKitNames += [className]
            }
        }
        return styleKitNames
    }()

    open static func styleKit(for name: String) -> StyleKit? {
        var styleKit: StyleKit? = nil
        let className: String?
        let components = name.components(separatedBy: ".")
        switch components.count {
        case 2:
            className = name
        default:
            className = styleKitNames.first { styleKitName in
                name == styleKitName.components(separatedBy: ".").last!
            }
        }
        if let className = className {
            if let existingStyleKit = styleKitForNameDict[className] {
                styleKit = existingStyleKit
            } else {
                styleKit = StyleKit(name: className)
                styleKitForNameDict[className] = styleKit
            }
        }
        return styleKit
    }

    open static func drawing(forStyleKitName styleKitName: String,
                        drawingName: String) -> Drawing?
    {
        return styleKit(for: styleKitName)?.drawing(for: drawingName)
    }
    
    // MARK: - Full list functions
    
    // Calling any of these methods is expensive, since it executes every method and caches the returnValue. Use only for discovery, eg showing a browser of all drawings.
    
    fileprivate lazy var returnValueForClassMethodNameDict: [String: Any]? = {
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
    
    open lazy var colorNames: [String] = {
        return Array(self.colorsDict.keys)
    }()
    
    open lazy var drawingNames: [String] = {
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

    fileprivate func returnValue(forClassMethodName methodName: String) -> Any? {
        let returnValue: Any?
        if let returnValueForClassMethodNameDict = self.returnValueForClassMethodNameDict {
            returnValue = returnValueForClassMethodNameDict[methodName]
        } else {
            returnValue = self.paintCodeClass?.returnValue(forClassMethodName: methodName)
        }
        return returnValue
    }

    // MARK: - Plist

    fileprivate var bundle: Bundle {
        #if TARGET_INTERFACE_BUILDER // rendering in storyboard using IBDesignable
            let isInterfaceBuilder = true
        #else
            let isInterfaceBuilder = false
        #endif
        return StyleKit.bundle(isInterfaceBuilder: isInterfaceBuilder)
    }
    
    fileprivate static func bundle(isInterfaceBuilder: Bool) -> Bundle {
        let bundle = isInterfaceBuilder
            ? Bundle(for: self)
            : Bundle.main
        return bundle;
    }

    internal lazy var parameterDict: [String: Any] = {
        guard let fileName = self.className?.components(separatedBy: ".").last,
            let path = self.bundle.path(forResource: fileName, ofType: "plist"),
            var parameterDict = NSDictionary(contentsOfFile: path) as? [String: Any]
            else {
                debugPrint("failed to find plist for styleKit \"" + (self.className ?? "nil") + "\"")
                return [:]
        }
        //TODO: move filtering to another class with references to consts for keys
        for key in ["sizes", "sizesByPrefix", "derived"] {
            if let dictionary = parameterDict[key] as? [String: Any] {
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

    fileprivate var colorForNameDict = [String: UIColor]()

    open func color(for colorName: String) -> UIColor? {
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

    fileprivate var drawingForNameDict = [String: Drawing]()
    
    fileprivate func drawingName(forMethodName methodName: String) -> String? {
        return methodName.methodNameComponents?
            .first?.substring(from: Drawing.FileName.drawPrefix.endIndex).lowercaseFirstCharacter
    }
    
    internal func classMethodName(forDrawingName drawingName: String) -> String? {
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

    open func drawing(for drawingName: String) -> Drawing? {
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