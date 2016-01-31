//
//  ExportersRoot.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 31/01/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import Foundation

class ExportersRoot {
    
    // MARK: - Structs

    struct DefaultsKey {
        static let exporters = "exporters"
    }
    
    // MARK: - Variables
    
    private var exporters: [String: AnyObject] = {
        var exporters = [String: AnyObject]()
        if let savedExporters = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsKey.exporters) as? [String: AnyObject] {
            savedExporters.forEach { (key, value) in
                exporters[key] = value
            }
        }
        return exporters
    }()
    
    var count: Int {
        return exporters.count
    }
    
    var exporterNames: [String] {
        return exporters.keys.sort()
    }
    
    // MARK: - Functions

    func saveExporters() {
        NSUserDefaults.standardUserDefaults().setObject(exporters, forKey: DefaultsKey.exporters)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func exporterForName(name: String) -> [String: AnyObject]? {
        return exporters[name] as? [String: AnyObject]
    }

    func exporterNameAtIndex(index: Int) -> String {
        return exporterNames[index]
    }
    
    func exporterAtIndex(index: Int) -> [String: AnyObject]? {
        return exporters[exporterNames[index]] as? [String: AnyObject]
    }
    
    func removeExporterForName(name: String) {
        exporters.removeValueForKey(name)
    }
    
    func removeExporterAtIndex(index: Int) {
        exporters.removeValueForKey(exporterNames[index])
    }
    
    func addExporterWithName(name: String) {
        exporters[name] = [String: AnyObject]();
    }
    
}