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
        self.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        self.separatorStyle = .none
        self.backgroundColor = FileExplorerColors.LightGrey
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
