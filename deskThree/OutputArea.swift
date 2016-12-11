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
    func makeBlock(for sender: OutputArea, withLocale blockLocation: CGPoint) -> Block
}

class OutputArea: UIButton {
    
    //MARK: Variables
    var typeOfOutputArea: Int?
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
        self.layer.cornerRadius = 10
    }
    
    //MARK: events
    func scootBlock( _ recognizer: UIPanGestureRecognizer) {
        let translationOfTouch = recognizer.translation(in: self)
        //this code runs when the touch has left the view, and the block hasn't been made yet
        if((!self.frame.contains(recognizer.location(in: superview!)) && !madeMyBlockYet)){
            if ((self.currentTitle?.characters.count)! > 0) {
                var newBlock = delegate!.makeBlock(for: self, withLocale: recognizer.location(in: self))
                lastBlockCreated = newBlock
                locationOfView = lastBlockCreated!.center
                madeMyBlockYet = true
            }
        }
    
        // This code passes the incremental views to InputObject
        if((lastBlockCreated) != nil){
        lastBlockCreated!.frame.origin = translationOfTouch + locationOfView!
            amtMoved += abs(translationOfTouch.x + translationOfTouch.y)
            if(amtMoved >= 30.0){
                self.delegate!.outputAreaDidPassIncrementalMove(movedView: lastBlockCreated!)
                amtMoved = 0.0
            }
        }

        //when the touch has ended
        if(recognizer.state == UIGestureRecognizerState.ended){
            
            //lastBlockCreated?.center = recognizer.location(in: self)
            
            if ((lastBlockCreated) != nil) {
                delegate!.outputAreaDidPassBlock(lastBlock: lastBlockCreated!)
                lastBlockCreated = nil
                madeMyBlockYet = false
            }
        }
    }
    
    
    
    
}

extension CGPoint {
 static func +(left: CGPoint, right:CGPoint) -> CGPoint {
        var returnVal: CGPoint = CGPoint()
        returnVal.x = left.x + right.x
        returnVal.y = left.y + right.y
        return returnVal
    }
}
