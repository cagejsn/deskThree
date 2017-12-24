//
//  StrokeToMathToggleControl.swift
//  deskThree
//
//  Created by Cage Johnson on 12/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import UIKit

protocol StrokeToMathToggleControlDelegate {
    
}


class StrokeToMathToggleControl: UIButton {
    
    var delegate: StrokeToMathToggleControlDelegate!
//    var isSelected: Bool = false
    
    
    
    override open var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.init(red: 17/255, green: 181/255, blue: 228/255, alpha: 1.0) : UIColor.init(red: 214/255, green: 242/255, blue: 251/255, alpha: 1.0) 
        }
    }
    /*
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.init(red: 214/255, green: 242/255, blue: 251/255, alpha: 1.0) : UIColor.init(red: 17/255, green: 181/255, blue: 228/255, alpha: 1.0)
        }
    }
 */
    
    
    
    
}
