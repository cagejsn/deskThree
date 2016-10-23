//
//  ImageBlock.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

protocol ImageBlockDelegate {
    func fixImageToWorkArea(image: ImageBlock)
    func freeImageForMovement(image: ImageBlock)
}

class ImageBlock: UIImageView, UIGestureRecognizerDelegate {
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    var zoomGR: UIPinchGestureRecognizer?
    var editable: Bool = false
    var delegate: ImageBlockDelegate! = nil

    //MARK: Custom Methods
    func toggleEditable(){
        if(!editable){
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.purple.cgColor
            editable = true
            delegate!.freeImageForMovement(image: self)
        } else{
            self.layer.borderColor = UIColor.clear.cgColor
            editable = false
            delegate!.fixImageToWorkArea(image: self)
            
        }
    }
    
    // MARK: touch handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(editable){
            superview!.bringSubview(toFront: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(editable){
            let touch: AnyObject = touches.first as UITouch!
            let currentTouch = touch.location(in: self)
            let previousTouch = touch.previousLocation(in: self)
            let dx = currentTouch.x - previousTouch.x
            let dy = currentTouch.y - previousTouch.y
            self.frame = self.frame.offsetBy(dx: dx, dy: dy)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func handleDoubleTap( sender: UITapGestureRecognizer) {
        toggleEditable()
    }
    
    func handlePinch( sender: UIPinchGestureRecognizer){
        /*
        if(editable){
            if (sender.state == UIGestureRecognizerState.Changed) {
                if(sender.scale <= 1){
                    self.transform = CGAffineTransformScale(self.transform, 0.99 , 0.99)
                } else {
                    self.transform = CGAffineTransformScale(self.transform, 1.01 , 1.01)
                }
            }
        }
    */
    }
    
    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageBlock.handleDoubleTap))
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(ImageBlock.handlePinch))
        zoomGR!.delegate = self
        self.addGestureRecognizer(zoomGR!)
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.purple.cgColor
        editable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
