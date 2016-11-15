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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! SwitchCell
        let choice = choices[indexPath.row]
        cell.textLabel?.text = choice.title
        cell.detailTextLabel?.text = choice.detail
        cell.onSwitch?.isOn = choice.chosen
        return cell
    }

    // MARK: - Actions
    
    @IBAction func changedSwitch(_ sender: UISwitch) {
        if let cell = sender.superviewCell,
            let indexPath = tableView.indexPath(for: cell)
        {
            var choice = choices[indexPath.row]
            choice.chosen = sender.isOn
            delegate?.choicesViewController(self, didChange: choice)
        }
    }
    
}

protocol ChoicesDelegate {
    
    func choicesViewController(_ choicesViewController: ChoicesViewController, didChange choice: Choice)
    
}
