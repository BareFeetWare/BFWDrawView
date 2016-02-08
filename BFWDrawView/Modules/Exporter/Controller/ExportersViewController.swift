//
//  ExportersViewController.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/01/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

class ExportersViewController: UITableViewController {

    // MARK: - Enums
    
    enum Section: Int {
        case Exporter = 0
        case Add = 1
    }
    
    enum Cell: String {
        case Exporter = "exporter"
        case Add = "add"
    }
    
    // MARK: - Model
    
    let exportersRoot = ExportersRoot()
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if exportersRoot.count == 0 {
            setEditing(true, animated: true)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let exporterViewController = segue.destinationViewController as? ExporterViewController,
            cell = sender as? UITableViewCell
        {
            if let indexPath = tableView.indexPathForCell(cell) {
                exporterViewController.exporter = exportersRoot.exporterAtIndex(indexPath.row)
            }
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let indexSet = NSIndexSet(index: Section.Add.rawValue)
        if editing {
            tableView.insertSections(indexSet, withRowAnimation: .Left)
        } else {
            tableView.deleteSections(indexSet, withRowAnimation: .Left)
        }
    }

    // MARK: - UITableViewController

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.editing ? 2 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let section = Section(rawValue: section) {
            switch section {
            case .Exporter:
                count = exportersRoot.count
            case .Add:
                count = 1
            }
        }
        return count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let section = Section(rawValue: indexPath.section) {
            switch section {
            case .Exporter:
                cell = tableView.dequeueReusableCellWithIdentifier(Cell.Exporter.rawValue, forIndexPath: indexPath)
                let exporter = exportersRoot.exporterAtIndex(indexPath.row)
                cell.textLabel?.text = exporter.name
                let platformString = (exporter.isAndroid ?? true) ? "Android" : "iOS"
                cell.detailTextLabel?.text = platformString + ": " + (exporter.drawingsStyleKitNames?.joinWithSeparator(", ") ?? "")
            case .Add:
                cell = tableView.dequeueReusableCellWithIdentifier(Cell.Add.rawValue, forIndexPath: indexPath)
            }
        } else {
            cell = UITableViewCell()
        }
        return cell
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        var style: UITableViewCellEditingStyle = .None
        if let section = Section(rawValue: indexPath.section) {
            switch section {
            case .Exporter:
                style = .Delete
            case .Add:
                style = .Insert
            }
        }
        return style
    }
    
    override func tableView(
        tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete {
            exportersRoot.removeExporterAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            addExporter()
        }
    }

    // MARK: - Actions
    
    private func addExporter() {
        let alertController = UIAlertController(title: "Exporter Name", message: "Enter the name of the new exporter", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "New exporter name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (alertAction) in
            if let exporterName = alertController.textFields?.first?.text {
                let exporter = Exporter()
                exporter.name = exporterName
                self.exportersRoot.addExporter(exporter)
                let indexPath = NSIndexPath(forRow: self.exportersRoot.count - 1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alertAction) in
            // Just dismiss.
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
