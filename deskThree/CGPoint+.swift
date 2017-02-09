//
//  CGPoint+.swift
//  deskThree
//
//  Created by Cage Johnson on 2/2/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


extension CGPoint {
    
    // add like vector
    static func +(left: CGPoint, right:CGPoint) -> CGPoint {
        var returnVal: CGPoint = CGPoint()
        returnVal.x = left.x + right.x
        returnVal.y = left.y + right.y
        return returnVal
    }
    // subtract like vector
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        var returnVal: CGPoint = CGPoint()
        returnVal.x = left.x - right.x
        returnVal.y = left.y - right.y
        return returnVal
    }
}
