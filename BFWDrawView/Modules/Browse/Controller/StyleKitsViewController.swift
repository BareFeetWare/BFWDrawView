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
    
    private var styleKitNames: [String] = (BFWStyleKit.styleKitNames() as! [String]).sort()

    // MARK: - Actions

    @IBAction func changedSwitch(sender: UISwitch) {
        if let cell = sender.superviewCell,
            indexPath = tableView.indexPathForCell(cell)
        {
            let styleKitName = styleKitNames[indexPath.row]
            let isInList = selectedStyleKitNames?.contains(styleKitName) ?? true
            if sender.on {
                if !isInList {
                    selectedStyleKitNames?.append(styleKitName)
                }
            } else {
                if (isInList) {
                    if let index = selectedStyleKitNames?.indexOf(styleKitName) {
                        selectedStyleKitNames?.removeAtIndex(index)
                    }
                }
            }
            delegate?.styleKitsViewController(self, didChangeNames: selectedStyleKitNames!)
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.styleKitNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SwitchCell
        let styleKitName = self.styleKitNames[indexPath.row]
        cell.textLabel?.text = styleKitName
        let styleKit = BFWStyleKit(forName:styleKitName)
        // TODO: Get drawingNames and colorNames on background thread since it is CPU expensive and pauses UI.
        cell.detailTextLabel?.text = "\(styleKit.drawingNames.count) drawings, \(styleKit.colorNames.count) colors"
        if let selectedStyleKitNames = selectedStyleKitNames {
            cell.onSwitch?.on = selectedStyleKitNames.contains(styleKitName)
        } else {
            cell.onSwitch?.hidden = true
        }
        return cell
    }

    // MARK: - UIViewController

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? BFWStyleKitViewController,
            cell = sender as? UITableViewCell,
            indexPath = tableView.indexPathForCell(cell)
        {
            let styleKitName = styleKitNames[indexPath.row]
            destinationViewController.styleKit = BFWStyleKit(forName:styleKitName)
        }
    }

}

protocol StyleKitsDelegate {
    func styleKitsViewController(styleKitsViewController: StyleKitsViewController, didChangeNames names: [String])
}

extension UIView {
    
    var superviewCell: UITableViewCell? {
        var cell: UITableViewCell?
        var view: UIView? = self
        while view != nil {
            if let tryCell = view as? UITableViewCell {
                cell = tryCell
                break
            } else {
                view = view?.superview
            }
        }
        return cell;
    }

}