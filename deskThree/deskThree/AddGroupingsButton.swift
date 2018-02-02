//
//  AddGroupingsButton.swift
//  deskThree
//
//  Created by Cage Johnson on 12/3/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class AddGroupingButton: UIButton {
    
    var bottomBorder: CALayer!
    
    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.imageView?.contentMode = .scaleAspectFit
        self.setImage(#imageLiteral(resourceName: "addNewGrouping"), for: .normal)
        self.imageEdgeInsets = UIEdgeInsetsMake(27, 27, 11, 11)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
