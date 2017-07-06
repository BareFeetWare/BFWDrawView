//
//  Updatable.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 5/7/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//

import UIKit

public protocol Updatable {
    
    // MARK: - Required

    var needsUpdateView: Bool { get set }
    func setNeedsUpdateView()
    
    // MARK: - Implemented by default extension:
    
    func updateViewIfNeeded()
    func updateView()
}

extension Updatable where Self: UIView {

    mutating func setNeedsUpdateView() {
        needsUpdateView = true
        setNeedsLayout()
    }
    
    private mutating func updateViewIfNeeded() {
        if needsUpdateView {
            needsUpdateView = false
            updateView()
        }
    }

}
