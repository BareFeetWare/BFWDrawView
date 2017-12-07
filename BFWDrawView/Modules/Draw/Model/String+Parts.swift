//
//  String+Parts.swift
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 7/12/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

extension String {
    
    func substring(beforeSuffix suffix: String) -> String? {
        return hasSuffix(suffix)
            ? String(self[..<index(at: -suffix.count)])
            : nil
    }
    
    func index(at int: Int) -> Index {
        return index(int < 0 ? endIndex : startIndex,
                     offsetBy: int)
    }

}
