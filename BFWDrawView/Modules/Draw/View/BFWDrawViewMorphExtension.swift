//
//  BFWDrawViewMorphExtension.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 17/02/2016.
//  Copyright © 2016 BareFeetWare. All rights reserved.
//

import UIKit

extension BFWDrawView {
    
    func isMorphableTo(drawView: BFWDrawView) -> Bool {
        var isMorphable = tag != 0 && tag == drawView.tag
        if !isMorphable {
            isMorphable = drawView.styleKit == styleKit && drawView.name == name
        }
        return isMorphable
    }
    
}
