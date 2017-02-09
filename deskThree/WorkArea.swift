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
    
    var pages: [Paper] = [Paper]()
    var currentPage: Paper!
    
    var longPressGR: UILongPressGestureRecognizer!
    
    init(){
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        pages.append(Paper())
        self.addSubview(pages[0])
        currentPage = pages[0]
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[0].contentMode = .scaleAspectFit
        self.sendSubview(toBack: pages[0])
        pages[0].isUserInteractionEnabled = true
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(WorkArea.handleLongPress))
        longPressGR.minimumPressDuration = 2
        self.addGestureRecognizer(longPressGR)
        
        
    }
    
   
    
    func handleLongPress(sender: UILongPressGestureRecognizer){
        
        
        let view = hitTest(sender.location(in: self), with: nil)
        if let imageBlock = view as? ImageBlock {
            if(!imageBlock.isEditable()){
            imageBlock.toggleEditable()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pages.append(Paper())
        self.addSubview(pages[0])
        currentPage = pages[0]
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[0].contentMode = .scaleAspectFit
        self.sendSubview(toBack: pages[0])
        pages[0].isUserInteractionEnabled = true
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(WorkArea.handleLongPress))
        longPressGR.minimumPressDuration = 0.7
        longPressGR.cancelsTouchesInView = true
        self.addGestureRecognizer(longPressGR)

    }
}
