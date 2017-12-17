//
//  ProjectNameLabel.swift
//  deskThree
//
//  Created by Cage Johnson on 12/3/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class ProjectNameLabel: UILabel {
    
    
    override required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold)
        self.textColor = UIColor.white
        
        
    }
    
    override func drawText(in rect: CGRect) {
        let offsetRect = rect.offsetBy(dx: 5, dy: 0)
        super.drawText(in: offsetRect)
    }
}
