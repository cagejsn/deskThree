//
//  workArea.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

protocol WorkAreaDelegate {
    func intersectsWithTrash(justMovedBlock: UIView)->Bool
    func unhideTrash()
    func hideTrash()
}

class WorkArea: UIScrollView, InputObjectDelegate, ExpressionDelegate, ToolDrawerDelegate {
    
    var pages: [Paper] = [Paper]()
    var currentPage: Paper!
    var longPressGR: UILongPressGestureRecognizer!
    var customDelegate: WorkAreaDelegate!
    
    func didEvaluate(forExpression sender: Expression, result: Float){
        var newBlock = InputObject.makeBlockForOutputArea(blockLocation: CGPoint(x: sender.frame.origin.x + (sender.frame.width / 2) , y: sender.frame.origin.y + (3 * sender.frame.height)), blockType: TypeOfBlock.Number.rawValue, blockData: String(result))
        newBlock.removeFromSuperview()
        var express = Expression(firstVal: newBlock)
        currentPage.addSubview(express)
        express.tag = -1
        currentPage.expressions.append(express)
        express.delegate = self
        newBlock.frame.origin = CGPoint.zero
        express.addSubview(newBlock)
    }
    
    func didCompleteMove(_movedView: UIView){
        //checks if the block's been dropped above any of the dummy views
        //if the block is not above an existing BlockGroup's dummy view, then we create a new blockgroup including only the new block
        var workingView = _movedView
        
        /*check if expression overlaps with trash bin*/
        if(customDelegate.intersectsWithTrash(justMovedBlock: _movedView)){
            print("deleting expression")
            currentPage.expressions.removeObject(object: _movedView)
            _movedView.isHidden = true
            return
        }
        
        if let block = _movedView as? Block {
            var expression = Expression(firstVal: block)
            expression.tag = -1
            
            expression.frame.origin = currentPage.convert(_movedView.frame.origin, from: _movedView.superview!)
           
            currentPage.addSubview(expression)
            expression.addSubview(block)
            currentPage.expressions.append(expression)
            expression.delegate = self
            block.frame.origin = CGPoint.zero
            block.parentExpression = expression
            workingView = expression
        }
        if var expression = workingView as? Expression {
            for group in currentPage.expressions {
                if(group != expression ){
                    for glow in group.dummyViews{
                        //see if any of the glow blocks contain the expression's origin
                        if(glow.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y).intersects(expression.frame)){
                            //reset the position to be on the x,y coords of the "group"
                            expression.frame = expression.frame.offsetBy(dx: -group.frame.origin.x, dy: -group.frame.origin.y)
                            //removes from superview, we need to refrain from doing this because of the possibility that the _movedView becomes the superview
                            expression.removeFromSuperview()
                            group.addSubview(expression)
                            
                            //animate merging of groups and rearrange the ETree
                            //group.animateMove(movedView: expression, dummy: glow)
                            
                            expression.frame = glow.frame
                            
                            group.frame = expression.frame.offsetBy(dx: group.frame.origin.x, dy:group.frame.origin.y ) + group.frame
                            // ^ IS SAME AS BELOW ?
                            //group.frame = group.frame.union(expression.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y))
                            
                            //sets frame to include both rectangles
                            //maybe change this to a new function.. make new Expression frame
                            
                            //finally merge the expressions
                            let parent = glow.parent
                            if glow == parent?.leftChild{
                                parent?.isAvailableOnLeft = false
                                ETree.getRightestNode(root: expression.rootBlock).isAvailableOnRight = false
                                group.hideSpots()
                                group.mergeExpressions(incomingExpression: expression , side: "left")
                                
                                //set the position of, and reassign ownership of, the blocks that were added
                                for sub in expression.subviews {
                                    sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                    sub.removeFromSuperview()
                                    group.addSubview(sub)
                                }
                                
                                //set the origins of the subviews to deal with the origin of the group having moved
                                for sub in group.subviews {
                                    sub.frame = sub.frame.offsetBy(dx: glow.frame.width, dy: 0)
                                }
                            }
                            if glow == parent?.rightChild{
                                parent?.isAvailableOnRight = false
                                ETree.getLeftestNode(root: expression.rootBlock).isAvailableOnLeft = false
                                group.hideSpots()
                                group.mergeExpressions(incomingExpression: expression , side: "right")
                                for sub in expression.subviews {
                                    sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                    sub.removeFromSuperview()
                                    group.addSubview(sub)
                                }
                            }
                            if glow == parent?.innerChild{
                                group.hideSpots()
                                group.mergeExpressions(incomingExpression: expression , side: "inner")
                                for sub in expression.subviews {
                                    sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                    sub.removeFromSuperview()
                                    group.addSubview(sub)
                                }
                            }
                            //get rid of old expression, may need to make sure that there are no more references
                            currentPage.expressions.removeObject(object: expression)
                            expression.isHidden = true
                        }
                    }
                }
            }
        }
        hideAllSpots()  
        
    }
    func didIncrementMove(_movedView: UIView){
        var zoomedView = CGRect() //temp CGRect
        //if the block is from an InputObject
        if let movedBlock = _movedView as? Block {
            zoomedView = movedBlock.frame
            
            zoomedView.origin = currentPage.convert(movedBlock.frame.origin, from: movedBlock.superview!)
            //zoomedView.origin = CGPoint(x: (self.contentOffset.x + movedBlock.frame.origin.x ) / self.zoomScale, y: (self.contentOffset.y + movedBlock.frame.origin.y) / self.zoomScale)
        }
        //if a preexisting expression is being moved
        if let movedExpression = _movedView as? Expression {
            zoomedView = movedExpression.frame
        }
        for group in currentPage.expressions {
            if(group != _movedView){
                if(group.isNear(incomingFrame: zoomedView)){
                    if(group.isDisplayingSpots == false){
                        group.findAndShowAvailableSpots(_movedView: _movedView)
                        //this will send the message to "group" that it needs to show its available spots for movedView
                    }
                    continue
                }
                group.hideSpots()
            }
        }
        if(customDelegate.intersectsWithTrash(justMovedBlock: _movedView)){
           // trashBin.open()
        }
        else{
           // trashBin.closed()
        }

        
    }
    func hideTrash(){
        customDelegate.hideTrash()
    }
    func unhideTrash(){
        customDelegate.unhideTrash()
    }
    
    
    
 
 
    func hideAllSpots() {
        for expression in currentPage.expressions {
            expression.hideSpots()
        }
    }

    func handleLongPress(sender: UILongPressGestureRecognizer){
        let view = hitTest(sender.location(in: self), with: nil)
        if let imageBlock = view as? ImageBlock {
            if(!imageBlock.isEditable()){
                imageBlock.toggleEditable()
            }
        }
    }
    
    init(){
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        pages.append(Paper())
        self.addSubview(pages[0])
        currentPage = pages[0]
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[0].contentMode = .scaleAspectFit
        self.sendSubview(toBack: pages[0])
        pages[0].isUserInteractionEnabled = true
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(WorkArea.handleLongPress))
        longPressGR.minimumPressDuration = 2
        self.addGestureRecognizer(longPressGR)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pages.append(Paper())
        self.addSubview(pages[0])
        currentPage = pages[0]
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[0].contentMode = .scaleAspectFit
        self.sendSubview(toBack: pages[0])
        pages[0].isUserInteractionEnabled = true
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(WorkArea.handleLongPress))
        longPressGR.minimumPressDuration = 0.7
        longPressGR.cancelsTouchesInView = true
        self.addGestureRecognizer(longPressGR)

    }
}
