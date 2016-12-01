//
//  outputArea.swift
//  EngineeringDesk
//
//  Created by Cage Johnson on 10/2/15.
//  Copyright (c) 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

//MARK: delegate
protocol OutputAreaDelegate{
    func outputAreaDidPassIncrementalMove(movedView: UIView)
    func outputAreaDidPassBlock (lastBlock: Block)
    func makeBlockForOutputArea (blockLocation: CGPoint, blockType: Int, blockData: String) -> Block
}

class OutputArea: UIButton {
    
    //MARK: Variables
    var typeOfInputObject: Int?
    var madeMyBlockYet = false
    var amtMoved: CGFloat = 0.0
    var lastBlockCreated: Block?
    var panGestureRecognizer: UIGestureRecognizer?
    var locationOfView: CGPoint?
    var delegate: OutputAreaDelegate?
    
    
    //MARK: Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "scootBlock:")
        self.addGestureRecognizer(panGestureRecognizer!)
        self.alpha = 0.8
        self.layer.cornerRadius = 10
    }
    
    
    //MARK: events
    func scootBlock( _ recognizer: UIPanGestureRecognizer) {
        
        let translationOfTouch = recognizer.translation(in: self)
        //print (recognizer.locationInView(superview!))
        //this code runs when the touch has left the view, and the block hasn't been made yet
        if((!self.frame.contains(recognizer.location(in: superview!)) && !madeMyBlockYet)){
            if ((self.currentTitle?.characters.count)! > 0) {
                let newBlock = delegate!.makeBlockForOutputArea(blockLocation: recognizer.location(in: superview!), blockType: self.typeOfInputObject!, blockData: self.currentTitle!)
                lastBlockCreated = newBlock
                
                locationOfView = lastBlockCreated!.center
                madeMyBlockYet = true
            }
        }
     
        if((lastBlockCreated) != nil){
            
            lastBlockCreated!.center.x = translationOfTouch.x + locationOfView!.x
            lastBlockCreated!.center.y = translationOfTouch.y + locationOfView!.y
            
            amtMoved += abs(translationOfTouch.x + translationOfTouch.y)
            if(amtMoved >= 30.0){
                self.delegate!.outputAreaDidPassIncrementalMove(movedView: lastBlockCreated!)
                amtMoved = 0.0
            }
        }

        //when the touch has ended
        if(recognizer.state == UIGestureRecognizerState.ended){
            
            if ((lastBlockCreated) != nil) {
                delegate!.outputAreaDidPassBlock(lastBlock: lastBlockCreated!)
                lastBlockCreated = nil
                madeMyBlockYet = false
            }
        }
    }
  
    
}
