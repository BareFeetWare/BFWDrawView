//
//  DrawingView+Morph.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 17/02/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

// TODO: Refactor as a protocol extension?

extension DrawingView {
    
    override func isMorphable(to view: UIView) -> Bool {
        var isMorphable = tag != 0 && tag == view.tag
        if !isMorphable {
            if let drawingView = view as? DrawingView,
                let drawing = drawingView.drawing
            {
                isMorphable = drawing == self.drawing
            }
        }
        return isMorphable
    }
    
}
