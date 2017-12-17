//
//  GroupingTableViewCell.swift
//  deskThree
//
//  Created by Cage Johnson on 9/24/17.
//  Copyright © 2017 desk. All rights reserved.
//

let groupingTableViewCellHeight = 80

import Foundation
import UIKit

class GroupingTableViewCell: UITableViewCell {
    
    let groupingColorDot: CAShapeLayer = {() -> CAShapeLayer in
        var layer = CAShapeLayer()
        return layer
    }()
    var label:UILabel!
    
    init(frame: CGRect, text: String, color: CGColor){
        //super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        super.init(style: .default, reuseIdentifier: "GroupingCell" )
        //super.init(frame: frame)
        label = UILabel(frame:
        { () -> CGRect in
            var go = frame.divided(atDistance: frame.height, from: .minXEdge)
            groupingColorDot.frame = go.slice.offsetBy(dx: 2, dy: 0)
            return go.remainder.insetBy(dx: 1, dy: 0).offsetBy(dx: 2, dy: 0)
            }()
        )
        
        let radius = self.frame.height/2
        
        groupingColorDot.path = UIBezierPath(ovalIn: groupingColorDot.frame.insetBy(dx: 25, dy: 25)).cgPath
        
        groupingColorDot.fillColor = color
        
        label.text = text
        stylizeText()
        self.addSubview(label)
        self.layer.addSublayer(groupingColorDot)        
        self.backgroundColor = FileExplorerColors.LightGrey
        
        self.selectedBackgroundView = { () -> UIView in let v = UIView(); v.backgroundColor = UIColor.white; return v}()
        label.highlightedTextColor = FileExplorerColors.DarkTextColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func stylizeText(){
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: ".SFUIText-Medium", size: 24)
        label.textColor = FileExplorerColors.DarkGrey
        
    }
    
    
    
}
