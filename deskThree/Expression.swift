//
//  BlockGroup.swift
//  EngineeringDesk
//
//  Created by Alejandro Silveyra on 9/8/15.
//  Copyright (c) 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

protocol ExpressionDelegate {
    func didIncrementMove(_movedView: UIView)
    func didCompleteMove(_movedView: UIView)
    func didEvaluate(result: Float)
}

class Expression: UIView, UIGestureRecognizerDelegate {
    
    //MARK: Variables
    
    var isDisplayingSpots: Bool = false
    var dummyViews: [Block] = []
    var amtMoved: CGFloat = 0
    var rootBlock: Block
    var delegate: ExpressionDelegate?
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    //MARK: UIGestureRecognizers
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
    //MARK: Initialization
    
    init(firstVal: Block){
        rootBlock = firstVal
        super.init(frame: CGRectInset(firstVal.frame,0,0))
        self.backgroundColor = UIColor.whiteColor()
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap")
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.addGestureRecognizer(panGestureRecognizer!)
        self.panGestureRecognizer?.cancelsTouchesInView = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    //MARK: Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //your code here
        superview!.bringSubviewToFront(self)
        }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: AnyObject = touches.first as UITouch!
        let currentTouch = touch.locationInView(self)
        let previousTouch = touch.previousLocationInView(self)
        let dx = currentTouch.x - previousTouch.x
        let dy = currentTouch.y - previousTouch.y
        let isInsideBounds = isMoveInsideBound(self.frame.origin.x + dx, y:self.frame.origin.y + dy, width: self.frame.width, height:self.frame.height)
        if (isInsideBounds) {
            if(amtMoved >= 10){
                self.delegate!.didIncrementMove(self)
                amtMoved = 0
            }
            amtMoved += (abs(dx) + abs(dy))
            self.frame = CGRectOffset(self.frame, dx, dy)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // will need to run the equivalent to move completed
        self.delegate!.didCompleteMove(self)
    }
    
    
    //MARK: Gesture Recognizer Method
    
    
    func handlePan(sender: UIPanGestureRecognizer){
        
    }
    
    func handleDoubleTap(){
        self.backgroundColor = UIColor.blueColor()
        if(ETree.canBeEvaluated(self.rootBlock)){
           delegate!.didEvaluate(Float(ETree.evaluate(self.rootBlock)))
        }
    }
    
    //MARK: Support Methods
    func isMoveInsideBound (x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) -> Bool {
        if (x >= superview!.frame.origin.x && x + width <= superview!.frame.size.width) {
            if (y >= superview!.frame.origin.y && y + height <= superview!.frame.size.height - 44) {
                return true
            }
        }
        return false
    }
    
    func isNear(incomingView: UIView) -> Bool{
        if(CGRectIntersectsRect(self.frame.insetBy(dx: -60, dy: -60), incomingView.frame)){
            return true
        }
        return false
    }
    
    //this function has a long way to go
    func findAndShowAvailableSpots(_movedView: UIView){
        //first find out what kind of View it is
        if let block = _movedView as? Block {
            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(block)
        }
        if let expression = _movedView as? Expression {
            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(ETree.getLeftestNode(expression.rootBlock))
            
            dummyViews.appendContentsOf(self.rootBlock.makeAListOfSpotsBelowMe(ETree.getRightestNode(expression.rootBlock)))
        }
        
        for dummy in dummyViews {
            addSubview(dummy)
            dummy.hidden = false
            dummy.layer.borderWidth = 1.0
        }
        isDisplayingSpots = true
    }
    
    func hideSpots(){
        self.rootBlock.removeDummyBlocks() //set revert to nil for real block
        self.dummyViews.removeAll() //clearout global dummy list
        isDisplayingSpots = false
    }
    
    func animateMove(movedView: UIView, dummy: UIView) {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        CATransaction.setCompletionBlock({
            movedView.userInteractionEnabled = true
        })
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        let finalPosition: CGPoint = dummy.frame.origin
        
        positionAnimation.duration = 0.5
        positionAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        positionAnimation.fromValue = NSValue(CGPoint:movedView.center)
        positionAnimation.toValue = NSValue(CGPoint: dummy.center)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.removedOnCompletion = false
        
        movedView.layer.addAnimation(positionAnimation, forKey: "positionAnimation")
       // movedView.layer.position = finalPosition
        
        CATransaction.commit()
    }
    
    
    //unwritten function
    func mergeExpressions(incomingExpression: Expression, side: String) {
        
        var incomingRootBlock = incomingExpression.rootBlock
        
        switch (side) {
            
            case "left":
                ETree.addLeft(rootBlock, lesserBlock: incomingRootBlock)
                break
            case "right":
                ETree.addRight(rootBlock, lesserBlock: incomingRootBlock)
                break
            case "inner":
                break
        
            default:
                break
        }

        
            //if the incoming expression is of a higher precedence, then make its root the new root.
            //the ETree should have been rearranged properly in the previous functions
            if(incomingExpression.rootBlock.precedence > rootBlock.precedence){
                self.rootBlock = incomingExpression.rootBlock
            }
            ETree.setParentGroup(self.rootBlock, parentGroup: self)
            ETree.printCurrentTree(self.rootBlock)
        
            //Expressions aren't ready because they number blocks don't have a
            //Double Value yet
        /*
 
        if(ETree.canBeEvaluated(self.rootBlock)){
             print( ETree.evaluate(self.rootBlock))
        }
 
        */
        
    }
}


