//
//  SwitchCell.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 25/01/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {

    private var overridingTextLabel: UILabel?
    private var overridingDetailTextLabel: UILabel?
    
    @IBOutlet override var textLabel: UILabel? {
        get {
            return overridingTextLabel
        }
        set {
            overridingTextLabel = newValue
        }
    }
    @IBOutlet override var detailTextLabel: UILabel? {
        get {
            return overridingDetailTextLabel
        }
        set {
            overridingDetailTextLabel = newValue
        }
    }
    @IBOutlet var onSwitch: UISwitch?
    
}
