//
//  UserView.swift
//  deskThree
//
//  Created by Cage Johnson on 10/21/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class UserView: UIView {
    
    var leftBorder: CALayer!
    var bottomBorder: CALayer!
    var userAvatarView: UIImageView!
    var userNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stylize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        stylize()
    }
    
    
    func stylize(){
        leftBorder = addAndReturnLeftBorder(color: FileExplorerColors.DeskBlue, width: 5)
        bottomBorder = addAndReturnBottomBorder(color: FileExplorerColors.DeskBlue, width: 5)
        self.backgroundColor = UIColor.clear
        
    }
    
    func removeBorders(){
        bottomBorder.removeFromSuperlayer()
        bottomBorder = nil
        leftBorder.removeFromSuperlayer()
        leftBorder = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        removeBorders()
        stylize()
    }
    
}
