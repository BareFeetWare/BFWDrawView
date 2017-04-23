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
    
}
