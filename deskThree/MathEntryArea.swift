//
//  mathEntryArea.swift
//  deskThree
//
//  Created by Cage Johnson on 12/19/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation

protocol MathEntryAreaDelegate {
    func didProduceBlockFromMath()
}

class MathEntryArea: OutputArea {
    
    var lhsValue: Int?
        
    override func scootBlock( _ recognizer: UIPanGestureRecognizer) {
        let translationOfTouch = recognizer.translation(in: self)
        //this code runs when the touch has left the view, and the block hasn't been made yet
        if((!self.frame.contains(recognizer.location(in: superview!)) && !madeMyBlockYet)){
            if ((self.currentTitle?.characters.count)! > 0) {
                var newBlock = makeBlock(withLocale: recognizer.location(in: self))
                lastBlockCreated = newBlock
                locationOfView = lastBlockCreated!.center
                madeMyBlockYet = true
                //set local text
                self.setTitle("", for: .normal)
                //set owner's text storage which is used by all the calc buttons, must typecast to MathEntryAreaDelegate bc there is a special function for MathEntryArea past OutputArea
                if let allPad = delegate as? MathEntryAreaDelegate {
                    allPad.didProduceBlockFromMath()
                }
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
            if ((lastBlockCreated) != nil) {
                delegate!.outputAreaDidPassBlock(lastBlock: lastBlockCreated!)
                lastBlockCreated = nil
                madeMyBlockYet = false
            }
        }
    }
    
}
