//
//  ToolDrawer.swift
//  deskThree
//
//  Created by Cage Johnson on 1/31/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

let toolSelectorHeight = 100
let toolDrawerCollapsedWidth:CGFloat = 40
let toolDrawerExpandedWidth:CGFloat = 291

enum DrawerPosition {
    case closed
    case open
}

protocol ToolDrawerDelegate {
    
    
}

class ToolDrawer: UIView {
    
    var activePad: InputObject!
    var drawerPosition = DrawerPosition.closed
    var panGestureRecognizer: UIPanGestureRecognizer!
    var isActive: Bool = false
    var previousTranslation: CGFloat = 0
    var delegate: InputObjectDelegate!
    
    //view controller for passing errors
    var rightConstaint: NSLayoutConstraint!
    var bottomContraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!
    var widthContraint: NSLayoutConstraint!
    
    func isPanValidForMovement(dx: CGFloat) -> Bool{
        if (self.frame.width - dx > toolDrawerCollapsedWidth && self.frame.width - dx < toolDrawerExpandedWidth){return true}
        return false
    }
    
    func handlePan(sender: UIPanGestureRecognizer){
        let touch = sender.location(in: self)
        let selector = Int(touch.y) / toolSelectorHeight
        let currentTranslation = sender.translation(in: self).x
        
        if(sender.state == .began){
            
        }
        
        var dx: CGFloat = 0
        if (sender.state == .changed){
            dx = currentTranslation - previousTranslation
            previousTranslation = currentTranslation
            if(isPanValidForMovement(dx: dx)){
                self.frame.origin.x += (dx/2)
                self.frame = self.frame.insetBy(dx: (dx/2), dy: 0)
            }
        }
        
        if (!isActive){
            switch (selector) {
            case 0:
                activePad = AllPad(frame: CGRect(x: toolDrawerCollapsedWidth, y: 0, width: Constants.dimensions.AllPad.width, height: Constants.dimensions.AllPad.height))
                self.addSubview(activePad)
                activePad.delegate = delegate
                isActive = true
                break
            case 1:
                break
            default:
                break
            }
            
        } else {
   
        }
        
        if(sender.state == .ended){
            if(drawerPosition == DrawerPosition.closed){
                animateToExpandedPosition()
                drawerPosition = DrawerPosition.open

            } else {
                animateToCollapsedPosition()
                drawerPosition = DrawerPosition.closed
            }
            previousTranslation = 0
        }
    }
    
    func animateToCollapsedPosition(){
        self.isUserInteractionEnabled = false
        //position animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        
        //position animation
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        let originPosition: CGPoint = self.center
        let finalPosition: CGPoint = self.center + CGPoint(x: self.frame.width - toolDrawerCollapsedWidth, y: 0)
        
        CATransaction.setCompletionBlock({
            self.isUserInteractionEnabled = true
            self.center = finalPosition
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: toolDrawerCollapsedWidth, height: 731)
            self.adjustWidthConstraint()
        })
        
        positionAnimation.duration = 1
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.fromValue = NSValue(cgPoint: originPosition)
        positionAnimation.toValue = NSValue(cgPoint: finalPosition)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = true
        self.layer.add(positionAnimation, forKey: "positionAnimation")
        CATransaction.commit()
        
    }
    
    func animateToExpandedPosition(){
        //position animation
        
        self.isUserInteractionEnabled = false
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        
        //position animation
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        let originPosition: CGPoint = self.center
        let finalPosition: CGPoint = self.center - CGPoint(x: toolDrawerExpandedWidth - self.frame.width , y: 0)
        
        CATransaction.setCompletionBlock({
            self.isUserInteractionEnabled = true
            self.center = finalPosition
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: toolDrawerExpandedWidth, height: 731)
            self.adjustWidthConstraint()
        })
        
        positionAnimation.duration = 1
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.fromValue = NSValue(cgPoint: originPosition)
        positionAnimation.toValue = NSValue(cgPoint: finalPosition)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = true
        self.layer.add(positionAnimation, forKey: "positionAnimation")
        CATransaction.commit()
       
    }
    
    func adjustWidthConstraint(){
        superview?.removeConstraint(widthContraint)
        widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.frame.width)
        superview!.addConstraint(widthContraint)
    }
    
    func setupConstraints(){
        self.translatesAutoresizingMaskIntoConstraints = false
        rightConstaint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1.0, constant: 0)
        bottomContraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1.0, constant: -44)
        heightContraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 731)
        widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        superview!.addConstraints([rightConstaint,bottomContraint,heightContraint,widthContraint])
    }
    
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 731))
        self.backgroundColor = UIColor.gray
        self.layer.cornerRadius = 10
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
        var lastHeight = 0
        for height in stride(from: 0, to: Int(self.frame.height), by: toolSelectorHeight) {
            print(height)
            var imageView = UIImageView(frame: CGRect(x: 0, y: lastHeight, width: Int(toolDrawerCollapsedWidth), height: height - lastHeight))
            lastHeight = height
            imageView.image = UIImage(named:"apple")
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
        }
    }
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
        self.layer.cornerRadius = 10
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
        var lastHeight = 0
        for height in stride(from: 0, to: Int(self.frame.height), by: toolSelectorHeight) {
            print(height)
            var imageView = UIImageView(frame: CGRect(x: 0, y: lastHeight, width: Int(toolDrawerCollapsedWidth), height: height - lastHeight))
            lastHeight = height
            imageView.image = UIImage(named:"apple")
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
        var lastHeight = 0
        for height in stride(from: 0, to: Int(self.frame.height), by: toolSelectorHeight) {
            print(height)
            var imageView = UIImageView(frame: CGRect(x: 0, y: lastHeight, width: Int(toolDrawerCollapsedWidth), height: height - lastHeight))
            lastHeight = height
            imageView.image = UIImage(named:"apple")
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
        }
    }  
}
