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
    
    class var classMethodNames: [String] {
        var names = [String]()
        var count: UInt32 = 0
        if let methods = class_copyMethodList(object_getClass(self), &count) {
            for index in 0 ..< Int(count) {
                if let method = methods[index],
                    let selector = method_getName(method)
                {
                    let name = String(describing: selector)
                    names += [name]
                }
            }
        }
        return names
    }
    
    class func returnValue(forClassMethodName methodName: String) -> Any {
//        let classType = "@"
//        let voidType = "v"
        let metaClass = objc_getMetaClass(NSStringFromClass(self).UTF8String)
        let method = class_getClassMethod(metaClass, NSSelectorFromString(methodName))
        let returnType = method_copyReturnType(method)
        let typeString = NSString.stringWithUTF8String(returnType)
        let returnValue = nil
        switch typeString {
        case classType:
            // Danger: calling method may have side effects
            let invocation = NSInvocation.invocationForClass(self, selector: NSSelectorFromString(methodName))
            // TODO: more direct way
            invocation.invoke()
            let tempReturnValue: __unsafe_unretained
            invocation.getReturnValue(&tempReturnValue)
            returnValue = tempReturnValue
        case voidType:
            returnValue = NSNull.null
        default:
            debugPrint("**** unexpected returnType = " + returnType)
        }
        free(returnType)
        return returnValue
    }
    
    class var returnValueForClassMethodNameDict: [String: Any] {
        var dictionary = [String: Any]()
        for methodName in classMethodNames {
            if let returnValue = returnValue(forClassMethodName: methodName) {
                dictionary[methodName] = returnValue
            }
        }
        return dictionary
    }

}
