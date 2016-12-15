//
//  BFWStyleKitDrawing.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 19/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import Foundation

class Drawing {

    struct FileName {
        static let drawPrefix = "draw"
    }

    var styleKit: StyleKit
    var name: String
    fileprivate var didSetDrawnSize = false

    enum Key: String {
        case sizes, sizesByPrefix
    }
    
    // MARK: - Init

    init(styleKit: StyleKit, name: String) {
        self.styleKit = styleKit
        self.name = name
    }
    
    // MARK: Variables

    lazy var methodName: String? = {
        return self.styleKit.classMethodName(forDrawingName: self.name)
    }()

    lazy var methodParameters: [String] = {
        let methodParameters: [String]
        if let methodNameComponents = self.methodName?.methodNameComponents as? [String],
            methodNameComponents.count > 1
        {
            methodParameters = Array(methodNameComponents.suffix(from: 1))
        } else {
            methodParameters = []
        }
        return methodParameters
    }()
    
    lazy var lookupName: String = {
        return self.name.lowercaseWords
    }()

    lazy var drawnSize: CGSize? = {
        let parameterDict = self.styleKit.parameterDict
        let sizeString: String?
        if let sizesDict = parameterDict[Key.sizes.rawValue],
            let matchedSizeString = (sizesDict as NSDictionary).object(forWordsKey: self.lookupName) as? String
        {
            //        if let matchedSizeString = (parameterDict[Key.sizes.rawValue] as? NSDictionary).objectForWordsKey(self.lookupName) {
            sizeString = matchedSizeString
        } else if let sizesDict = parameterDict[Key.sizesByPrefix.rawValue] {
            sizeString = (sizesDict as NSDictionary).objectForLongestPrefixKeyMatchingWords(in: self.lookupName) as? String
        } else {
            sizeString = nil
        }
        return sizeString.flatMap { CGSizeFromString($0) }
    }()

    var intrinsicFrame: CGRect? {
        guard let drawnSize = drawnSize
            else { return nil }
        return CGRect(origin: CGPoint.zero, size: drawnSize)
    }

}
