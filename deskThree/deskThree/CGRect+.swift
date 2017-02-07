//
//  CGRect+.swift
//  deskThree
//
//  Created by Cage Johnson on 2/5/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
//custom operator extension for CGRect
extension CGRect {
    static func +(left: CGRect , right: CGRect) -> CGRect{
        var returnRect: CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: left.width + right.width, height: left.height))
        if(left.origin.x < right.origin.x){
            returnRect.origin = left.origin
        } else {
            returnRect.origin = right.origin
        }
        return returnRect
    }
}
