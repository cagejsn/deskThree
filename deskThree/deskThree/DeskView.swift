//
//  DeskView.swift
//  deskThree
//
//  Created by Cage Johnson on 2/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class DeskView: UIView, UIGestureRecognizerDelegate{
    
    var longPressGR: UILongPressGestureRecognizer!

    
    func setup(){
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(DeskView.handleLongPress(sender:)))
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

    
   
    
}
