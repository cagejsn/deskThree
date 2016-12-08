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
    
    //MARK: UIGestureRecognizers
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
    //MARK: Initialization
    
    init(firstVal: Block){
        rootBlock = firstVal
        super.init(frame: firstVal.frame.insetBy(dx: 0,dy: 0))
      // self.backgroundColor = UIColor.white
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap")
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Touch Events

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview!.bringSubview(toFront: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject = touches.first as UITouch!
        let currentTouch = touch.location(in: self)
        let previousTouch = touch.previousLocation(in: self)
        let dx = currentTouch.x - previousTouch.x
        let dy = currentTouch.y - previousTouch.y
        let isInsideBounds = isMoveInsideBound(x: self.frame.origin.x + dx, y:self.frame.origin.y + dy, width: self.frame.width, height:self.frame.height)
        if (isInsideBounds) {
            if(amtMoved >= 10){
                self.delegate!.didIncrementMove(_movedView: self)
                amtMoved = 0
            }
            amtMoved += (abs(dx) + abs(dy))
            self.frame = self.frame.offsetBy(dx: dx, dy: dy)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.delegate!.didCompleteMove(_movedView: self)
    }
    
    //MARK: Gesture Recognizer Methods
    func handleDoubleTap(){
        if(ETree.canBeEvaluated(node: self.rootBlock)){
           delegate!.didEvaluate(result: Float(ETree.evaluate(node: self.rootBlock)))
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
    
    func isNear(incomingFrame: CGRect) -> Bool{
        if(self.frame.insetBy(dx: -60, dy: -60).intersects(incomingFrame)){
            return true
        }
        return false
    }
    
    //this function has a long way to go
    func findAndShowAvailableSpots(_movedView: UIView){
        //first find out what kind of View it is
        if let block = _movedView as? Block {
            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: block)
        }
        if let expression = _movedView as? Expression {
            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: ETree.getLeftestNode(root: expression.rootBlock))
            
            dummyViews.append(contentsOf: self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: ETree.getRightestNode(root: expression.rootBlock)))
        }
        
        for dummy in dummyViews {
            addSubview(dummy)
            dummy.isHidden = false
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
            movedView.isUserInteractionEnabled = true
        })
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        let finalPosition: CGPoint = dummy.frame.origin
        
        positionAnimation.duration = 0.5
        positionAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        positionAnimation.fromValue = NSValue(cgPoint:movedView.center)
        positionAnimation.toValue = NSValue(cgPoint: dummy.center)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = false
        
        movedView.layer.add(positionAnimation, forKey: "positionAnimation")
       // movedView.layer.position = finalPosition
        
        CATransaction.commit()
    }
    
    
    //unwritten function
    func mergeExpressions(incomingExpression: Expression, side: String) {
        
        var incomingRootBlock = incomingExpression.rootBlock
        
        switch (side) {
            
            case "left":
                ETree.addLeft(persistentBlock: rootBlock, lesserBlock: incomingRootBlock)
                break
            case "right":
                ETree.addRight(lastingBlock: rootBlock, lesserBlock: incomingRootBlock)
                break
            case "inner":
                break
        
            default:
                break
        }

        
            //if the incoming expression is of a higher precedence, then make its root the new root.
            //the ETree should have been rearranged properly in the previous functions
            if(incomingExpression.rootBlock.precedence! > rootBlock.precedence!){
                self.rootBlock = incomingExpression.rootBlock
            }
            ETree.setParentGroup(node: self.rootBlock, parentGroup: self)
            ETree.printCurrentTree(root: self.rootBlock)
        
            //Expressions aren't ready because they number blocks don't have a
            //Double Value yet
        /*
 
        if(ETree.canBeEvaluated(self.rootBlock)){
             print( ETree.evaluate(self.rootBlock))
        }
 
        */
        
    }
}


