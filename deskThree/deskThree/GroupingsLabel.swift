//
//  GroupingsLabel.swift
//  deskThree
//
//  Created by Cage Johnson on 12/3/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class GroupingsLabel: UILabel {
    
    var bottomBorder: CALayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textColor = FileExplorerColors.DarkGrey
        bottomBorder = addAndReturnBottomBorder(color: FileExplorerColors.FaintlyDarkLightGrey, width: 1)
    }
    
    override func drawText(in rect: CGRect) {
        var offsetRect = rect.offsetBy(dx: 50, dy: 5)
        super.drawText(in: offsetRect)
    }
}
