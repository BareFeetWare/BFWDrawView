//
//  ChoicesViewController.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 5/02/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

typealias Choice = (title: String, detail: String, value: AnyObject, chosen: Bool)

class ChoicesViewController: UITableViewController {

    // MARK: - Public variables
    
    var choices: [Choice] = []
    var delegate: ChoicesDelegate?
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("switch", forIndexPath: indexPath) as! SwitchCell
        let choice = choices[indexPath.row]
        cell.textLabel?.text = choice.title
        cell.detailTextLabel?.text = choice.detail
        cell.onSwitch?.on = choice.chosen
        return cell
    }

    // MARK: - Actions
    
    @IBAction func changedSwitch(sender: UISwitch) {
        if let cell = sender.superviewCell,
            let indexPath = tableView.indexPathForCell(cell)
        {
            var choice = choices[indexPath.row]
            choice.chosen = sender.on
            delegate?.choicesViewController(self, didChangeChoice: choice)
        }
    }
    
}

protocol ChoicesDelegate {
    
    func choicesViewController(choicesViewController: ChoicesViewController, didChangeChoice choice: Choice)
    
}