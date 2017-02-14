//
//  DeskView.swift
//  deskThree
//
//  Created by Cage Johnson on 2/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class DeskView: UIView, UIGestureRecognizerDelegate{
    
    var workArea: WorkArea!
    var jotView: JotView!
    var panGR: UIPanGestureRecognizer!


    
    func setup(){
        panGR = UIPanGestureRecognizer(target: self, action: #selector(DeskView.handlePan(sender:)))
        panGR.maximumNumberOfTouches = 1
       // self.addGestureRecognizer(panGR)
        panGR.delegate = self
        jotView.currentPage = workArea.currentPage
    }
    
    func handlePan(sender: UIPanGestureRecognizer){
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        let f = NSSet(object: touch)
        
        jotView.touchesBegan(f as! Set<UITouch>, with: nil   )
        return true
    }
    
}
