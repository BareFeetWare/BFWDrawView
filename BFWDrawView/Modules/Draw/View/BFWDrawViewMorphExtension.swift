//
//  BFWDrawViewMorphExtension.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 17/02/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

extension BFWDrawView {
    
    override func isMorphableTo(view: UIView) -> Bool {
        var isMorphable = tag != 0 && tag == view.tag
        if !isMorphable {
            if let drawView = view as? BFWDrawView {
                isMorphable = drawView.styleKit == styleKit && drawView.name == name
            }
        }
        return isMorphable
    }
    
}
