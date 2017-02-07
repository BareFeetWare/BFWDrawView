//
//  StyleKitsViewController.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import UIKit

class StyleKitsViewController: UITableViewController {

    // MARK: - Variables

    var selectedStyleKitNames: [String]?

    var delegate: StyleKitsDelegate?
    
    fileprivate var styleKitNames: [String] = StyleKit.styleKitNames.sorted()

    // MARK: - Actions

    @IBAction func changedSwitch(_ sender: UISwitch) {
        if let cell = sender.superviewCell,
            let indexPath = tableView.indexPath(for: cell)
        {
            let styleKitName = styleKitNames[indexPath.row]
            let isInList = selectedStyleKitNames?.contains(styleKitName) ?? true
            if sender.isOn {
                if !isInList {
                    selectedStyleKitNames?.append(styleKitName)
                }
            } else {
                if isInList {
                    if let index = selectedStyleKitNames?.index(of: styleKitName) {
                        selectedStyleKitNames?.remove(at: index)
                    }
                }
            }
            delegate?.styleKitsViewController(self, didChange: selectedStyleKitNames!)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return styleKitNames.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SwitchCell
        let styleKitName = self.styleKitNames[indexPath.row]
        cell.textLabel?.text = styleKitName
        let styleKit = StyleKit.styleKit(for: styleKitName)!
        // TODO: Get drawingNames and colorNames on background thread since it is CPU expensive and pauses UI.
        cell.detailTextLabel?.text = "\(styleKit.drawingNames.count) drawings, \(styleKit.colorNames.count) colors"
        if let selectedStyleKitNames = selectedStyleKitNames {
            cell.onSwitch?.isOn = selectedStyleKitNames.contains(styleKitName)
        } else {
            cell.onSwitch?.isHidden = true
        }
        return cell
    }

    // MARK: - UIViewController

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? StyleKitViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        {
            let styleKitName = styleKitNames[indexPath.row]
            destinationViewController.styleKit = StyleKit.styleKit(for:styleKitName)
        }
    }

}

protocol StyleKitsDelegate {
    func styleKitsViewController(_ styleKitsViewController: StyleKitsViewController, didChange names: [String])
}
