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
    func sendingToInputObject(for element: Any)
}

class WorkArea: UIScrollView, InputObjectDelegate, PaperDelegate {
    
    var pages: [Paper] = [Paper]()
    var currentPage: Paper!
    var currentPageIndex = 0
    var longPressGR: UILongPressGestureRecognizer!
    var customDelegate: WorkAreaDelegate!

    func passHeldBlock(sender: Expression) {
        customDelegate.sendingToInputObject(for: sender)
    }
    
    func setupDelegateChain(){
        for page in pages {
            page.delegate = self
            page.setupDelegateChain()
        }
    }
    
    func stylizeViews(){
        for page in pages {
            page.stylizeViews()
        }
    }
    
    
    // stores metadata of this workspace. Initialized to untitled. can be
    // replaced with setDeskProject
    var project: DeskProject!
    
    ///sets workarea's meta data object
    func setDeskProject(project: DeskProject){
        self.project = project
    }
    
    ///returns meta data for this workarea
    func getDeskProject() -> DeskProject {
        return project!
    }
    
    // MARK: Expression Delegate
    func didEvaluate(forExpression sender: Expression, result: Float){
        var newBlock = BlockExpression.makeBlock(blockLocation: CGPoint(x: sender.frame.origin.x + (sender.frame.width / 2) , y: sender.frame.origin.y + (3 * sender.frame.height)), blockType: TypeOfBlock.Number.rawValue, blockData: String(result))
        newBlock.removeFromSuperview()
        var express = BlockExpression(firstVal: newBlock)
        currentPage.addSubview(express)
        express.tag = -1
        currentPage.expressions.append(express as! BlockExpression)
        express.delegate = self.currentPage
        newBlock.frame.origin = CGPoint.zero
        express.addSubview(newBlock)
    }
    
    func elementWantsSendToInputObject(element:Any){
        customDelegate!.sendingToInputObject(for: element)
    }
    
    func didCompleteMove(_movedView: UIView){
        //checks if the block's been dropped above any of the dummy views
        //if the block is not above an existing BlockGroup's dummy view, then we create a new blockgroup including only the new block
        var workingView = _movedView
        
        /*check if expression overlaps with trash bin*/
        if(customDelegate.intersectsWithTrash(justMovedBlock: _movedView)){
            currentPage.expressions.removeObject(object: _movedView)
            _movedView.isHidden = true
            return
        }
        
        if let block = _movedView as? Block {
            var blockExpression = BlockExpression(firstVal: block)
            blockExpression.tag = -1
            
            blockExpression.frame.origin = currentPage.convert(_movedView.frame.origin, from: _movedView.superview!)
           
            currentPage.addSubview(blockExpression)
            blockExpression.addSubview(block)
            currentPage.expressions.append(blockExpression)
            blockExpression.delegate = self.currentPage
            block.frame.origin = CGPoint.zero
            block.parentExpression = blockExpression
            workingView = blockExpression
        }
        if var blockExpression = workingView as? BlockExpression {
            for group in currentPage.expressions {
                if let group = group as? BlockExpression {
                    if(group != blockExpression ){
                        for glow in group.getDummyViews(){
                            //see if any of the glow blocks contain the expression's origin
                            if(glow.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y).intersects(blockExpression.frame)){
                                //reset the position to be on the x,y coords of the "group"
                                blockExpression.frame = blockExpression.frame.offsetBy(dx: -group.frame.origin.x, dy: -group.frame.origin.y)
                                //removes from superview, we need to refrain from doing this because of the possibility that the _movedView becomes the superview
                                blockExpression.removeFromSuperview()
                                group.addSubview(blockExpression)
                                
                                //animate merging of groups and rearrange the ETree
                                //group.animateMove(movedView: expression, dummy: glow)
                                
                                blockExpression.frame = glow.frame
                                
                                group.frame = blockExpression.frame.offsetBy(dx: group.frame.origin.x, dy:group.frame.origin.y ) + group.frame
                                // ^ IS SAME AS BELOW ?
                                //group.frame = group.frame.union(expression.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y))
                                
                                //sets frame to include both rectangles
                                //maybe change this to a new function.. make new Expression frame
                                
                                //finally merge the expressions
                                let parent = glow.parent
                                if glow == parent?.leftChild{
                                    parent?.isAvailableOnLeft = false
                                    ETree.getRightestNode(root: blockExpression.rootBlock).isAvailableOnRight = false
                                    group.hideSpots()
                                    group.mergeExpressions(incomingExpression: blockExpression , side: "left")
                                    
                                    //set the position of, and reassign ownership of, the blocks that were added
                                    for sub in blockExpression.subviews {
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
                                    ETree.getLeftestNode(root: blockExpression.rootBlock).isAvailableOnLeft = false
                                    group.hideSpots()
                                    group.mergeExpressions(incomingExpression: blockExpression , side: "right")
                                    for sub in blockExpression.subviews {
                                        sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                        sub.removeFromSuperview()
                                        group.addSubview(sub)
                                    }
                                }
                                if glow == parent?.innerChild{
                                    group.hideSpots()
                                    group.mergeExpressions(incomingExpression: blockExpression , side: "inner")
                                    for sub in blockExpression.subviews {
                                        sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                        sub.removeFromSuperview()
                                        group.addSubview(sub)
                                    }
                                }
                                //get rid of old expression, may need to make sure that there are no more references
                                currentPage.expressions.removeObject(object: blockExpression)
                                blockExpression.isHidden = true
                            }
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
        }
        //if a preexisting expression is being moved
        if let movedExpression = _movedView as? Expression {
            zoomedView = movedExpression.frame
        }
        for group in currentPage.expressions {
            if let group = group as? BlockExpression {
                if(group != _movedView){
                    if(group.isNear(incomingFrame: zoomedView)){
                        if(group.getIsDisplayingSpots() == false){
                            group.findAndShowAvailableSpots(_movedView: _movedView)
                            //this will send the message to "group" that it needs to show its available spots for movedView
                        }
                        continue
                    }
                    group.hideSpots()
                }
            }
        }
    }
    
    func hideAllSpots() {
        for expression in currentPage.expressions {
            if let expression = expression as? BlockExpression {
            expression.hideSpots()
            }
        }
    }
    
    // MARK: trashbin
    func hideTrash(){
        customDelegate.hideTrash()
    }
    func unhideTrash(){
        customDelegate.unhideTrash()
    }
    
    
    /**
     Move to a page to the right
     If there is no page, add one and make it the current page
     */
    func movePage(direction: String) -> (currentPage: Int, totalNumPages: Int) {
        if direction == "right" {
            // Check if this is the last page
            if currentPageIndex == pages.count - 1 {
                currentPageIndex += 1
                
                // Add a new page
                pages.append(Paper())
                self.addSubview(pages[currentPageIndex])
                
                // Push back the old view
                self.sendSubview(toBack: pages[currentPageIndex - 1])
                pages[currentPageIndex - 1].isHidden = true
                
                // Bring forward the new view
                self.bringSubview(toFront: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = false
                
                currentPage = pages[currentPageIndex]
            } else {
                currentPageIndex += 1
                
                // Move forward a page
                currentPage = pages[currentPageIndex]
                
                // Push back the old view
                self.sendSubview(toBack: pages[currentPageIndex - 1])
                pages[currentPageIndex - 1].isHidden = true
                
                // Bring forward the new view
                self.bringSubview(toFront: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = false
            }
            
            initCurPage()
            
        } else if direction == "left" {
            // Check if this is the first page
            if currentPageIndex != 0 {
                
                // Push back the old view
                self.sendSubview(toBack: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = true
                
                currentPageIndex -= 1
                // Bring forward the new view
                self.bringSubview(toFront: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = false
                
                currentPage = pages[currentPageIndex]
                initCurPage()
            }
        }
        
        return (currentPageIndex, pages.count)
    }
    
    // MARK: init and helpers
    func initCurPage() {
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[currentPageIndex].contentMode = .scaleAspectFit
        currentPage.isUserInteractionEnabled = true
        setupForJotView()
    }
    
    func setupForJotView() {
        self.setZoomScale(minimumZoomScale, animated: false)
        self.setZoomScale((maximumZoomScale + minimumZoomScale)/2, animated: false)
        self.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func encode(with aCoder: NSCoder){
        super.encode(with: aCoder)
        aCoder.encode(pages)
    }
    
    init(){
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        var pape = Paper()
        pape.delegate = self
        pages.append(pape)
        self.addSubview(pages[0])
        currentPage = pages[0]
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[0].contentMode = .scaleAspectFit
        self.sendSubview(toBack: pages[0])
        pages[0].isUserInteractionEnabled = true
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        self.project = DeskProject(name: "Untitled")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialize the first page & set it as the current page
        let loadedPaper = aDecoder.decodeObject() as! [Paper]
        pages = loadedPaper
        self.currentPage = pages.first
        currentPage.isHidden = false
        
        for view in self.subviews{
            view.isHidden = true
        }
        
        self.addSubview(currentPage)
        currentPage.isHidden = false
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        currentPage.contentMode = .scaleAspectFit
       // self.sendSubview(toBack: currentPage)
        currentPage.isUserInteractionEnabled = true
        self.panGestureRecognizer.minimumNumberOfTouches = 2

        
    }
}
