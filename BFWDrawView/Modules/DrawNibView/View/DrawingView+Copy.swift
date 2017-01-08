//
//  DrawingView+Copy.swift
//
//  Created by Tom Brodhurst-Hill on 8/1/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

extension DrawingView {
    
    override func copyProperties(from view: UIView) {
        super.copyProperties(from: view)
        if let view = view as? DrawingView {
            drawing = view.drawing
        }
    }

}
