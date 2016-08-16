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

    private struct DefaultsKey {
        static let exporters = "exporters"
    }
    
    // MARK: - Private Variables
    
    private lazy var exporters: [Exporter] = {
        return self.loadingDictArray.map { exporterDict in
            let exporter = Exporter(dictionary: exporterDict)
            exporter.root = self
            return exporter
        }
    }()
    
    private var loadingDictArray: [[String: AnyObject]] = {
        var dictArray: [[String: AnyObject]]
        if let savedExportersDictArray = NSUserDefaults.standardUserDefaults().arrayForKey(DefaultsKey.exporters) as? [[String: AnyObject]] {
            dictArray = savedExportersDictArray
        } else if let bundledPlistPath = NSBundle.mainBundle().pathForResource("ExporterDefaults", ofType: "plist"),
            let defaultsDict = NSDictionary(contentsOfFile: bundledPlistPath) as? [String: AnyObject],
            let bundledDictArray = defaultsDict[DefaultsKey.exporters] as? [[String: AnyObject]]
        {
            dictArray = bundledDictArray
        } else {
            dictArray = [[String: AnyObject]]()
        }
        return dictArray
    }()
    
    private var savingDictArray: [[String: AnyObject]] {
        return exporters.map { exporter in
            exporter.dictionary
        }
    }
    
    // MARK: - Public Variables

    var count: Int {
        return exporters.count
    }
    
    var exporterNames: [String] {
        return exporters.map { exporter in
            exporter.name
        }
    }
    
    // MARK: - Functions

    func saveExporters() {
        NSUserDefaults.standardUserDefaults().setObject(savingDictArray, forKey: DefaultsKey.exporters)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func exporterForName(name: String) -> Exporter? {
        return exporters.filter { exporter -> Bool in
            exporter.name == name
        }.first
    }

    func exporterNameAtIndex(index: Int) -> String {
        return exporters[index].name
    }
    
    func exporterAtIndex(index: Int) -> Exporter {
        return exporters[index]
    }
    
    func removeExporterForName(name: String) {
        var deletedCount = 0
        exporters.enumerate().forEach { (index, exporter) in
            if exporter.name == name {
                exporters.removeAtIndex(index + deletedCount)
                deletedCount += 1
            }
        }
    }
    
    func removeExporterAtIndex(index: Int) {
        exporters.removeAtIndex(index)
    }
    
    func addExporter(exporter: Exporter) {
        exporter.root = self
        exporters.append(exporter)
    }
    
}