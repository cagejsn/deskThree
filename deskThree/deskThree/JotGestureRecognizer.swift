//
//  JotGestureRecognizer.swift
//  deskThree
//
//  Created by Cage Johnson on 2/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol JotGestureRecognizerDelegate {
    func panGestureRecognizerDelegate(gr: UIPanGestureRecognizer, touches: NSSet, andEvent:UIEvent)
        
    
}

class JotGestureRecognizer: UIGestureRecognizer{
    
    
   
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
     
    }
    
    
    
}
