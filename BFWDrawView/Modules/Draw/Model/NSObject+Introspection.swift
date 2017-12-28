//
//  NSObject+Introspection.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 23/4/17.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import Foundation

extension NSObject {
    
    static var allClasses: [AnyClass] {
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses)
        let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        var classes = [AnyClass]()
        for i in 0 ..< actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)] {
                classes.append(currentClass)
            }
        }
        allClasses.deallocate(capacity: Int(expectedClassCount))
        return classes
    }
    
    static func classes(implementingProtocol theProtocol: Protocol) -> [AnyClass] {
        return allClasses.filter { class_conformsToProtocol($0, theProtocol) }
    }
    
    static var classMethodNames: [String] {
        var methodCount: UInt32 = 0
        let classString = NSStringFromClass(self)
        guard let metaClass = objc_getMetaClass(classString) as? AnyClass,
            let methods = class_copyMethodList(metaClass, &methodCount)
            else { return [] }
        var names = [String]()
        for index in 0 ..< numericCast(methodCount) {
            let method = methods[index]
            if let selector: Selector = method_getName(method) {
                names += [String(_sel: selector)]
            }
        }
        return names
    }

    static var returnValueForClassMethodNameDict: [String: Any] {
        var mutableDictionary = [String: Any]()
        for methodName in classMethodNames {
            if let returnValue = returnValue(forClassMethodName: methodName) {
                mutableDictionary[methodName] = returnValue
            }
        }
        return mutableDictionary
    }
    
    static func classFunctionName(forDrawingName drawingName: String) -> String? {
        let drawingWords = "draw " + drawingName.lowercasedWords
        let methodName = classMethodNames.first { methodName in
            guard let baseName = methodName.methodNameComponents?.first,
                baseName.lowercasedWords == drawingWords
                else { return false }
            return true
        }
        return methodName
    }

}
