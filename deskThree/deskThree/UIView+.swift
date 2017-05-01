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
    
    @discardableResult func addAndReturnRightBorder(color: UIColor, width: CGFloat) -> CALayer {
        let layer = CALayer()
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.frame = CGRect(x: self.frame.size.width-width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(layer)
        return layer
    }
    @discardableResult func addAndReturnLeftBorder(color: UIColor, width: CGFloat) -> CALayer {
        let layer = CALayer()
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(layer)
        return layer
    }
    @discardableResult func addAndReturnTopBorder(color: UIColor, width: CGFloat) -> CALayer {
        let layer = CALayer()
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(layer)
        return layer
    }
    @discardableResult func addAndReturnBottomBorder(color: UIColor, width: CGFloat) -> CALayer {
        let layer = CALayer()
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.frame = CGRect(x: 0, y: self.frame.size.height-width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(layer)
        return layer
    }
}
