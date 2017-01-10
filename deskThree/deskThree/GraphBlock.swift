//
//  graphBlock.swift
//  deskThree
//
//  Created by Cage Johnson on 1/10/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class GraphBlock: GLKView {
    
    var zoomGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var touched: Bool = false
    
    override init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame, context: context)
        zoomGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch")
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan")
    }

   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = true
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first?.location(in: self)
        let prevTouchLocation = touches.first?.previousLocation(in: self)
        let dX =  touchLocation!.x - prevTouchLocation!.x
        let dY =  touchLocation!.y - prevTouchLocation!.y
        self.frame.origin.x += dX
        self.frame.origin.y += dY
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false
        setNeedsDisplay() 
    }
    
    func handlePinch(){
    }
    
    func handlePan(){
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
