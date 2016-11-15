//
//  DrawingCell.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 30/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//

import UIKit

class DrawingCell: UITableViewCell {

    // MARK: - Public variables
    
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
    @IBOutlet var drawView: DrawingView?

    // MARK: - Private variables
    
    fileprivate var overridingTextLabel: UILabel?
    fileprivate var overridingDetailTextLabel: UILabel?
    
}
