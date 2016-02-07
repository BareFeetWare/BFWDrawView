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
        var exporters = [Exporter]()
        self.loadingDictArray.forEach { exporterDict in
            let exporter = Exporter(dictionary: exporterDict)
            exporter.root = self
            exporters.append(exporter)
        }
        return exporters
    }()
    
    private var loadingDictArray: [[String: AnyObject]] = {
        var exportersDict: [[String: AnyObject]]
        if let savedExportersDict = NSUserDefaults.standardUserDefaults().arrayForKey(DefaultsKey.exporters) as? [[String: AnyObject]] {
            exportersDict = savedExportersDict
        } else {
            exportersDict = [[String: AnyObject]]()
        }
        return exportersDict
    }()
    
    private var savingDictArray: [[String: AnyObject]] {
        var exporterDictArray = [[String: AnyObject]]()
        exporters.forEach { exporter in
            exporterDictArray.append(exporter.dictionary)
        }
        return exporterDictArray
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
                deletedCount++
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