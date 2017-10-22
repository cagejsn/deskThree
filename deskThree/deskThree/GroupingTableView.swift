//
//  GroupingTableView.swift
//  deskThree
//
//  Created by Cage Johnson on 9/24/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import UIKit


class GroupingTableView: UITableView {
    
    var bottomBorder: CALayer?
    var leftBorder: CALayer?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        stylize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        stylize()
    }
    
    func stylize(){
     //   self.layer.cornerRadius = 10
        bottomBorder = addAndReturnBottomBorder(color: FileExplorerColors.DeskBlue, width: 5)
        leftBorder = addAndReturnLeftBorder(color: FileExplorerColors.DeskBlue, width: 5)
        self.separatorStyle = .none
     //   self.separatorStyle = .singleLine
      
        //self.round(corners: [.bottomLeft,.bottomRight], radius: 10)
       // self.layer.cornerRadius = 10
        //self.backgroundColor = FileExplorerColors.DarkGrey
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomBorder?.removeFromSuperlayer()
        bottomBorder = nil
        leftBorder?.removeFromSuperlayer()
        leftBorder = nil
        stylize()
        
        
    }
    
}
