//
//  ToolDrawer.swift
//  deskThree
//
//  Created by Cage Johnson on 1/31/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
#if !DEBUG
    import Mixpanel
#endif

let toolSelectorHeight = 100
let toolDrawerCollapsedWidth:CGFloat = 40
let toolDrawerExpandedWidth:CGFloat = 291


enum DrawerPosition {
    case closed
    case open
}

class ToolDrawer: UIView {
    var toolIcons: [UIImageView]!
    var calculatorIcon: UIImageView!

    var activePad: InputObject!
    var drawerPosition = DrawerPosition.closed
    var panGestureRecognizer: UIPanGestureRecognizer!
    var singleTapGR: UIGestureRecognizer!
    var isActive: Bool = false
    var previousTranslation: CGFloat = 0
    var delegate: InputObjectDelegate!
    let toolDrawerHeight: CGFloat = Constants.dimensions.AllPad.height

    //view controller for passing errors
    var rightConstaint: NSLayoutConstraint!
    var bottomContraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!
    var widthContraint: NSLayoutConstraint!

    // Mixpanel initialization
    #if !DEBUG
        var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif
    
    func receiveElement(_ element: Any){
        if(drawerPosition == .closed){
            return
        }
        if(!isActive){
            return
        }
        if(activePad != nil){
            activePad.receiveElement(element)
        }
    }
    
    func isPanValidForMovement(dx: CGFloat) -> Bool{
        if (self.frame.width - dx > toolDrawerCollapsedWidth && self.frame.width - dx < toolDrawerExpandedWidth){return true}
        return false
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if(calculatorIcon.frame.contains(point)){
            return true
        }
        if(activePad != nil){
            if(activePad.frame.contains(point)){
                return true
            }
        }
        return false
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer){
        #if !DEBUG
            mixpanel.track(event: "Gesture: Calculator: Single Touch Open/Close")
        #endif

        let location = sender.location(in: self)
        if (toolIcons[0].frame.contains(location)){
            if (!isActive){
                activePad = AllPad(frame: CGRect(x: toolDrawerCollapsedWidth, y: 0, width: Constants.dimensions.AllPad.width, height: Constants.dimensions.AllPad.height))
                self.addSubview(activePad)
                activePad.delegate = delegate
                isActive = true
                calculatorIcon.backgroundColor = UIColor.init(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 0.75)
            }
                if(drawerPosition == DrawerPosition.closed){
                    #if !DEBUG
                        mixpanel.track(event: "Gesture: Calculator: Open")
                    #endif

                    animateToExpandedPosition()
                    drawerPosition = DrawerPosition.open
                    
                } else {
                    #if !DEBUG
                        mixpanel.track(event: "Gesture: Calculator: Close")
                    #endif

                    animateToCollapsedPosition()
                    drawerPosition = DrawerPosition.closed
                }

        }
    }
    
    func handlePan(sender: UIPanGestureRecognizer){
        let currentTranslation = sender.translation(in: self).x
        
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
            activePad = AllPad(frame: CGRect(x: toolDrawerCollapsedWidth, y: 0, width: Constants.dimensions.AllPad.width, height: Constants.dimensions.AllPad.height))
            self.addSubview(activePad)
            activePad.delegate = delegate
            isActive = true
            calculatorIcon.backgroundColor = UIColor.init(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 0.75)
        }
        
        if(sender.state == .ended){
            if(self.frame.width >= (toolDrawerExpandedWidth/2)){
                animateToExpandedPosition()
                drawerPosition = DrawerPosition.open
            } else {
                animateToCollapsedPosition()
                drawerPosition = DrawerPosition.closed
            }
            previousTranslation = 0
        }
    }
    
    func deactivateActivePad(){
        activePad.removeFromSuperview()
        activePad.delegate = nil
        activePad = nil
        isActive = false
        
        for icon in toolIcons {
            icon.backgroundColor = UIColor.init(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 0.75)
        }
    }
    
    func animateToCollapsedPosition(){
        self.isUserInteractionEnabled = false
        
        //position animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        
        //position animation
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        self.frame = CGRect(x: self.frame.origin.x , y:self.frame.origin.y, width: toolDrawerCollapsedWidth, height: toolDrawerHeight)
        let originPosition: CGPoint = self.center
        let finalPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width - toolDrawerCollapsedWidth/2 , y: UIScreen.main.bounds.height - (toolDrawerHeight/2))
        CATransaction.setCompletionBlock({
            self.isUserInteractionEnabled = true
           self.deactivateActivePad()
        })
        
        positionAnimation.duration = 0.1
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.fromValue = NSValue(cgPoint: originPosition)
        positionAnimation.toValue = NSValue(cgPoint: finalPosition)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = true
        self.layer.add(positionAnimation, forKey: "positionAnimation")
        CATransaction.commit()
        self.setCollapsedWidthConstraint()
        self.center = finalPosition
        self.frame = CGRect(x:UIScreen.main.bounds.width - toolDrawerCollapsedWidth, y: UIScreen.main.bounds.height - (toolDrawerHeight), width: toolDrawerCollapsedWidth, height: toolDrawerHeight)
    }
    
    func animateToExpandedPosition(){
        //position animation
        self.isUserInteractionEnabled = false
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        
        //position animation
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        self.frame = CGRect(x: self.frame.origin.x , y:self.frame.origin.y, width: toolDrawerExpandedWidth, height: toolDrawerHeight)
        let originPosition: CGPoint = self.center
        let finalPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width - toolDrawerExpandedWidth/2 , y: UIScreen.main.bounds.height - (toolDrawerHeight/2))
        
        CATransaction.setCompletionBlock({
            self.isUserInteractionEnabled = true
        })
        
        positionAnimation.duration = 0.1
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.fromValue = NSValue(cgPoint: originPosition)
        positionAnimation.toValue = NSValue(cgPoint: finalPosition)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = true
        self.layer.add(positionAnimation, forKey: "positionAnimation")
        CATransaction.commit()
        self.setExpandedWidthConstraint()
        self.center = finalPosition
        self.frame = CGRect(x:UIScreen.main.bounds.width - toolDrawerExpandedWidth, y: UIScreen.main.bounds.height - (toolDrawerHeight), width: toolDrawerExpandedWidth, height: toolDrawerHeight)
    }
    
    func setCollapsedWidthConstraint(){
        superview?.removeConstraint(widthContraint)
        widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: toolDrawerCollapsedWidth)
        superview!.addConstraint(widthContraint)
    }
    
    func setExpandedWidthConstraint(){
        superview?.removeConstraint(widthContraint)
        widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: toolDrawerExpandedWidth)
        superview!.addConstraint(widthContraint)
    }
    
    func setupConstraints(){
        self.translatesAutoresizingMaskIntoConstraints = false
        rightConstaint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1.0, constant: 0)
        bottomContraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1.0, constant: 0)
        heightContraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Constants.dimensions.AllPad.height)
        widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: toolDrawerCollapsedWidth)
        superview!.addConstraints([rightConstaint,bottomContraint,heightContraint,widthContraint])
    }
        
    init(){
        // Setup the base view, which is transparent and has a shadow
        super.init(frame: CGRect(x: 0, y: 0, width: toolDrawerCollapsedWidth, height: Constants.dimensions.AllPad.height))
        
        // Add the swipe gesture for sliding out
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
        
        // Add the tap gesture for sliding out
        singleTapGR = UITapGestureRecognizer(target: self, action: #selector(ToolDrawer.handleSingleTap))
        self.addGestureRecognizer(singleTapGR)

        // Add the icon to the icon view
        calculatorIcon = UIImageView(frame:CGRect(x: 0, y: 0, width: Int(toolDrawerCollapsedWidth), height: toolSelectorHeight))
        calculatorIcon.image = UIImage(named: "calculator_med_white")
        calculatorIcon.contentMode = .scaleAspectFit
        
        // Change color of the icon view
        calculatorIcon.backgroundColor = UIColor.init(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 0.75)
        // Round the icon view
        calculatorIcon.round(corners: [.topLeft, .bottomLeft], radius: 5.0)
        self.addSubview(calculatorIcon)
        toolIcons = [UIImageView]()
        toolIcons.append(calculatorIcon)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
    }
}
