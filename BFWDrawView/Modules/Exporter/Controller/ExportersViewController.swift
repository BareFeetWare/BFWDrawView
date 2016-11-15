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
        case exporter = 0
        case add = 1
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
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if exportersRoot.count == 0 {
            setEditing(true, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let exporterViewController = segue.destination as? ExporterViewController,
            let cell = sender as? UITableViewCell
        {
            if let indexPath = tableView.indexPath(for: cell) {
                exporterViewController.exporter = exportersRoot.exporter(at: indexPath.row)
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        let indexSet = IndexSet(integer: Section.add.rawValue)
        if editing {
            tableView.insertSections(indexSet, with: .left)
        } else {
            tableView.deleteSections(indexSet, with: .left)
        }
    }

    // MARK: - UITableViewController

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.isEditing ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let section = Section(rawValue: section) {
            switch section {
            case .exporter:
                count = exportersRoot.count
            case .add:
                count = 1
            }
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let section = Section(rawValue: indexPath.section) {
            switch section {
            case .exporter:
                cell = tableView.dequeueReusableCell(withIdentifier: Cell.Exporter.rawValue, for: indexPath)
                let exporter = exportersRoot.exporter(at: indexPath.row)
                cell.textLabel?.text = exporter.name
                let platformString = (exporter.isAndroid ?? true) ? "Android" : "iOS"
                cell.detailTextLabel?.text = platformString + ": " + (exporter.drawingsStyleKitNames?.joined(separator: ", ") ?? "")
            case .add:
                cell = tableView.dequeueReusableCell(withIdentifier: Cell.Add.rawValue, for: indexPath)
            }
        } else {
            cell = UITableViewCell()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        var style: UITableViewCellEditingStyle = .none
        if let section = Section(rawValue: indexPath.section) {
            switch section {
            case .exporter:
                style = .delete
            case .add:
                style = .insert
            }
        }
        return style
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            exportersRoot.removeExporter(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            addExporter()
        }
        exportersRoot.saveExporters()
    }

    // MARK: - Actions
    
    fileprivate func addExporter() {
        let alertController = UIAlertController(title: "Exporter Name", message: "Enter the name of the new exporter", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "New exporter name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (alertAction) in
            if let exporterName = alertController.textFields?.first?.text {
                let exporter = Exporter()
                exporter.name = exporterName
                self.exportersRoot.append(exporter: exporter)
                let indexPath = IndexPath(row: self.exportersRoot.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .top)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            // Just dismiss.
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
