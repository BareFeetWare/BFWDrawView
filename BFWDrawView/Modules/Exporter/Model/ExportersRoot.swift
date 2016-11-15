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

    fileprivate struct DefaultsKey {
        static let exporters = "exporters"
    }
    
    // MARK: - Private Variables
    
    fileprivate lazy var exporters: [Exporter] = {
        return self.loadingDictArray.map { exporterDict in
            let exporter = Exporter(dictionary: exporterDict)
            exporter.root = self
            return exporter
        }
    }()
    
    fileprivate var loadingDictArray: [[String: AnyObject]] = {
        var dictArray: [[String: AnyObject]]
        if let savedExportersDictArray = UserDefaults.standard.array(forKey: DefaultsKey.exporters) as? [[String: AnyObject]] {
            dictArray = savedExportersDictArray
        } else if let bundledPlistPath = Bundle.main.path(forResource: "ExporterDefaults", ofType: "plist"),
            let defaultsDict = NSDictionary(contentsOfFile: bundledPlistPath) as? [String: AnyObject],
            let bundledDictArray = defaultsDict[DefaultsKey.exporters] as? [[String: AnyObject]]
        {
            dictArray = bundledDictArray
        } else {
            dictArray = [[String: AnyObject]]()
        }
        return dictArray
    }()
    
    fileprivate var savingDictArray: [[String: AnyObject]] {
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
        UserDefaults.standard.set(savingDictArray, forKey: DefaultsKey.exporters)
        UserDefaults.standard.synchronize()
    }
    
    func exporter(for name: String) -> Exporter? {
        return exporters.filter { exporter -> Bool in
            exporter.name == name
        }.first
    }

    func exporterName(at index: Int) -> String {
        return exporters[index].name
    }
    
    func exporter(at index: Int) -> Exporter {
        return exporters[index]
    }
    
    func removeExporter(for name: String) {
        var deletedCount = 0
        exporters.enumerated().forEach { (index, exporter) in
            if exporter.name == name {
                exporters.remove(at: index + deletedCount)
                deletedCount += 1
            }
        }
    }
    
    func removeExporter(at index: Int) {
        exporters.remove(at: index)
    }
    
    func append(exporter: Exporter) {
        exporter.root = self
        exporters.append(exporter)
    }
    
}
