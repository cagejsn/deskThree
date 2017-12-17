//
//  CurrentGroupingLabel.swift
//  deskThree
//
//  Created by Cage Johnson on 12/3/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class CurrentGroupingLabel: UILabel {
    
    
    
    override func drawText(in rect: CGRect) {
        var offsetRect = rect.offsetBy(dx: 0, dy: 5)
        super.drawText(in: offsetRect)
    }
    
    
    
    
    
}
