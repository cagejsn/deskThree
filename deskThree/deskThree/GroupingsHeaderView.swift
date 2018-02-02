//
//  GroupingsLabel.swift
//  deskThree
//
//  Created by Cage Johnson on 10/21/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class GroupingsHeaderView: UIView {
    
    var bottomBorder: CALayer!
    var leftBorder: CALayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stylize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        stylize()
    }
    
    func stylize(){
        self.backgroundColor = FileExplorerColors.LightGrey
    }
}
