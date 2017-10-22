//
//  GroupingsLabel.swift
//  deskThree
//
//  Created by Cage Johnson on 10/21/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class GroupingsLabel: UILabel {
    
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
        //self.round(corners: [.allCorners], radius: 10)
        self.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        self.textColor = FileExplorerColors.DarkTextColor
        self.backgroundColor = FileExplorerColors.LightGrey
        bottomBorder = addAndReturnBottomBorder(color: FileExplorerColors.DeskBlue, width: 5)
        leftBorder = addAndReturnLeftBorder(color: FileExplorerColors.DeskBlue, width: 5)
    }
    

    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 10, dy: 0))
    }
 
    
    func updateText(for selectedSegment: Int){
        switch selectedSegment {
        case 0:
            self.text = "Classes"
        case 1:
            self.text = "Skills"
        case 2:
            self.text = "Explore"
        case 3:
            self.text = "Settings"
        default:
            self.text = "what"
        }
    }
    
    
    
}
