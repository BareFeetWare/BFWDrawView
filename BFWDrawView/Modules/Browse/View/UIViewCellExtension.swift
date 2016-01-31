//
//  UIViewCellExtension.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 1/02/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

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
