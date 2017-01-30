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
    func fixImageToPage(image: ImageBlock)
    func freeImageForMovement(image: ImageBlock)
    func helpMove(imageBlock: ImageBlock, dx: CGFloat, dy: CGFloat) 
}

class ImageBlock: UIView, UIGestureRecognizerDelegate {
    
    var imageHolder: UIImageView!
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    var zoomGR: UIPinchGestureRecognizer?
    var rotationGestureRecognizer: UIRotationGestureRecognizer!
    var editable: Bool = false
    var delegate: ImageBlockDelegate! = nil
    var orientationInt: Int = 0
    
    var previousRotation: CGFloat = 0

    //MARK: Custom Methods
    func toggleEditable(){
        if(!editable){
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.purple.cgColor
            zoomGR?.isEnabled = true
            rotationGestureRecognizer.isEnabled = true
            editable = true
            delegate!.freeImageForMovement(image: self)
          //  isUserInteractionEnabled = true
            
            
        } else{
            self.layer.borderColor = UIColor.clear.cgColor
            editable = false
            delegate!.fixImageToPage(image: self)
            zoomGR?.isEnabled = false
            rotationGestureRecognizer.isEnabled = false
         //   isUserInteractionEnabled = false
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
            self.frame.origin.x += dx
            self.frame.origin.y += dy
           // delegate.helpMove(imageBlock:self, dx: dx, dy: dy)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    func handleRotate( sender: UIRotationGestureRecognizer){
        var dR = sender.rotation - previousRotation
        previousRotation = sender.rotation
        self.imageHolder.transform = self.imageHolder.transform.rotated(by: dR)
    }

    func handlePinch( sender: UIPinchGestureRecognizer){
        if(editable){
            if (sender.state == UIGestureRecognizerState.changed) {
                if(sender.velocity < 0){
                    self.imageHolder.transform = self.imageHolder.transform.scaledBy(x: 0.99 , y: 0.99)
                  //  self.bounds.size.width *= 0.99
                  //  self.bounds.size.height  *= 0.99
                } else {
                    self.imageHolder.transform = self.imageHolder.transform.scaledBy(x: 1.01 , y: 1.01)
                 //   self.bounds.size.width *= 1.01
                 //   self.bounds.size.height  *= 1.01
                }
            }
        }
    }

    func setImage(image: UIImage){
        imageHolder.image = image
    }

    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageHolder = UIImageView(frame: self.frame)
        self.addSubview(imageHolder)
        imageHolder.contentMode = .scaleAspectFit
        
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ImageBlock.handleRotate(sender:)))
        self.addGestureRecognizer(rotationGestureRecognizer)
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageBlock.toggleEditable))
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
