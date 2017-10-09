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
    
    
    
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        stylize()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        stylize()

    }
    
    
    func stylize(){
        self.layer.cornerRadius = 10
        //self.backgroundColor = UIColor.darkGray
    }
    
    
    
}
