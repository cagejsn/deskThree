//
//  DeskView.swift
//  deskThree
//
//  Created by Cage Johnson on 2/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class DeskView: UIView {
    
    var workArea: WorkArea!
    var jotView: JotView!
    
    var pan2GR: UIPanGestureRecognizer!
    var zoomGR: UIPinchGestureRecognizer!
    
    
    func handlePan(sender: UIPanGestureRecognizer){
        
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer){
        
    }
    
    func setup(){
        pan2GR = UIPanGestureRecognizer(target: self, action: #selector(DeskView.handlePan(sender:)))
        pan2GR.minimumNumberOfTouches = 2
        self.addGestureRecognizer(pan2GR)
        
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(DeskView.handlePinch(sender:)))
        self.addGestureRecognizer(zoomGR)
        
    }
    
}
