//
//  workArea.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit


extension UIView{
    
    func boundInsideBy(superView: UIView, x1:Int , x2:Int, y1:Int, y2:Int){
        self.translatesAutoresizingMaskIntoConstraints = false
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-a-[subview]-b-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics:["a":NSNumber(value: x1),"b":NSNumber(value: x2)], views:["subview":self]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-c-[subview]-d-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics:["c":NSNumber(value: y1),"d":NSNumber(value: y2)], views:["subview":self]))
    }
}

class WorkArea: UIScrollView {

    var background: UIImageView = UIImageView(image: UIImage(named: "engineeringPaper"))
    

    
    
   
    
    init(){
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        self.addSubview(background)
        background.contentMode = .scaleAspectFit
        self.sendSubview(toBack: background)
        background.isUserInteractionEnabled = true
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        self.panGestureRecognizer.cancelsTouchesInView = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
 
    
   
 
    
}
