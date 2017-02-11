//
//  UIView+.swift
//  deskThree
//
//  Created by Cage Johnson on 2/10/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

extension UIView{
    func boundInsideBy(superView: UIView, x1:Int , x2:Int, y1:Int, y2:Int){
        self.translatesAutoresizingMaskIntoConstraints = false
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-a-[subview]-b-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics:["a":NSNumber(value: x1),"b":NSNumber(value: x2)], views:["subview":self]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-c-[subview]-d-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics:["c":NSNumber(value: y1),"d":NSNumber(value: y2)], views:["subview":self]))
    }
}
