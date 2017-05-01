//
//  ImageBlock.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel

protocol ImageBlockDelegate: NSObjectProtocol {
    func fixImageToPage(image: ImageBlock)
    func freeImageForMovement(image: ImageBlock)
    func helpMove(imageBlock: ImageBlock, dx: CGFloat, dy: CGFloat)
    
    func didBeginMove(movedView: UIView)
    func didIncrementMove(movedView: UIView)
    func didCompleteMove(movedView: UIView)
}

class ImageBlock: UIView, UIGestureRecognizerDelegate {
    
    var imageHolder: UIImageView!
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    var zoomGR: UIPinchGestureRecognizer?
    var rotationGestureRecognizer: UIRotationGestureRecognizer!
    var editable: Bool = false
    weak var delegate: ImageBlockDelegate! = nil
    var previousRotation: CGFloat = 0

    // Mixpanel initialization
    var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")

    //MARK: Custom Methods
    func toggleEditable(){
        mixpanel.track(event: "Gesture: Image: Toggle Editable")

        if (!editable) {
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.purple.cgColor
            zoomGR?.isEnabled = true
            rotationGestureRecognizer.isEnabled = true
            doubleTapGestureRecognizer?.isEnabled = true
            editable = true
            delegate!.freeImageForMovement(image: self)
            isUserInteractionEnabled = true
        } else {
            self.layer.borderColor = UIColor.clear.cgColor
            editable = false
            delegate!.fixImageToPage(image: self)
            zoomGR?.isEnabled = false
            rotationGestureRecognizer.isEnabled = false
            doubleTapGestureRecognizer?.isEnabled = false
            isUserInteractionEnabled = false
            //superview?.sendSubview(toBack: self)
        }
        // This function is called so that the updated editable value is encoded
        // Find a better way to do this in the future
        delegate.didCompleteMove(movedView: self)
    }
    
    func isEditable()->Bool{
        return editable 
    }
    
    // MARK: touch handlers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(editable){
            superview!.bringSubview(toFront: self)
            delegate.didBeginMove(movedView: self)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(editable){
            delegate.didIncrementMove(movedView: self)
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
        if(editable){
        delegate.didCompleteMove(movedView: self)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if(self.point(inside: point, with: event)){
            if (event == nil){
                return self
            } else {
                return super.hitTest(point, with: event)
            }
        } else { return super.hitTest(point, with: event)}
    }
        
    func handleRotate( sender: UIRotationGestureRecognizer){
        mixpanel.track(event: "Gesture: Image: Handle Rotate")
        let dR = sender.rotation - previousRotation
        previousRotation = sender.rotation
        self.imageHolder.transform = self.imageHolder.transform.rotated(by: dR)
        if(sender.state == .ended){
            previousRotation = 0
        }
    }

    func handlePinch( sender: UIPinchGestureRecognizer){
        mixpanel.track(event: "Gesture: Image: Handle Pinch")

        if (editable) {
            if (sender.state == UIGestureRecognizerState.changed) {
                if(sender.velocity < 0){
                    self.imageHolder.transform = self.imageHolder.transform.scaledBy(x: 0.99 , y: 0.99)
                } else {
                    self.imageHolder.transform = self.imageHolder.transform.scaledBy(x: 1.01 , y: 1.01)
                }
            }
        }
    }
    
    

    func setImage(image: UIImage){
        mixpanel.track(event: "Gesture: Image: Set Image")

        imageHolder.image = image
    }

    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageBlock.toggleEditable))
        doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
        
        imageHolder = UIImageView(frame: self.frame)
        self.addSubview(imageHolder)
        imageHolder.contentMode = .scaleAspectFit
        
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ImageBlock.handleRotate(sender:)))
        self.addGestureRecognizer(rotationGestureRecognizer)
        
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(ImageBlock.handlePinch))
        zoomGR!.delegate = self
        self.addGestureRecognizer(zoomGR!)
        
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.purple.cgColor
        editable = true
    }
    
    
    //MARK: functions for encoding and decoding
    required init(coder unarchiver: NSCoder){
        super.init(coder: unarchiver)!
        imageHolder = unarchiver.decodeObject() as! UIImageView!
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageBlock.toggleEditable))
        doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
        
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(ImageBlock.handleRotate(sender:)))
        self.addGestureRecognizer(rotationGestureRecognizer)

        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(ImageBlock.handlePinch))
        zoomGR!.delegate = self
        self.addGestureRecognizer(zoomGR!)
        editable = unarchiver.decodeObject() as! Bool!
        if(editable){
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.purple.cgColor
        }

    }
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageHolder)
        aCoder.encode(editable)
        
    }
    
}
