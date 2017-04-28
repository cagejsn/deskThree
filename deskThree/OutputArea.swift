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
    func outputAreaCreatedBlock(newBlock: Block)

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
  
    func setupNewBlock( newBlock: inout Block){
        newBlock.text = currentTitle!
        newBlock.font = UIFont.boldSystemFont(ofSize: Constants.block.fontSize)
        newBlock.textColor = UIColor.white
        newBlock.type = typeOfOutputArea!
        newBlock.forBaselineLayout().clipsToBounds = true
        newBlock.forBaselineLayout().layer.cornerRadius = Constants.block.cornerRadius
    }
    
    //function below is the one that is actually used by OutputArea
    func makeBlock(withLocale blockLocation: CGPoint) -> Block {
        
        let blockWidth: CGFloat = Expression.evaluateStringWidth(textToEvaluate: currentTitle!)
        var newBlock = Block(frame: CGRect(x: 0, y: 0, width: blockWidth, height: Constants.block.height))
        delegate!.outputAreaCreatedBlock(newBlock: newBlock)
        switch typeOfOutputArea! {
        case 1:
            newBlock.setColor(color: Constants.block.colors.green)
            newBlock.precedence = Precedence.Number.rawValue
        case 2:
            newBlock.setColor(color: Constants.block.colors.blue)
            
            switch currentTitle! {
            case "+":
                newBlock.precedence = Precedence.Plus.rawValue
                break
            case "-":
                newBlock.precedence = Precedence.Minus.rawValue
                break
            case "✕":
                newBlock.precedence = Precedence.Multiply.rawValue
                break
            case "÷":
                newBlock.precedence = Precedence.Divide.rawValue
                break
            case "√":
                newBlock.precedence = Precedence.Multiply.rawValue
                break
            case "^":
                newBlock.precedence = Precedence.Multiply.rawValue
                break
            default:
                break
            }
        case 3:
            newBlock.setColor(color: Constants.block.colors.gray)
        default:
            //We shouldn't have a default
            break
        }
        setupNewBlock(newBlock: &newBlock)
        newBlock.center = blockLocation
        self.addSubview(newBlock)
        return newBlock
    }
    
    //MARK: events
    func scootBlock( _ recognizer: UIPanGestureRecognizer) {
        let translationOfTouch = recognizer.translation(in: self)
        //this code runs when the touch has left the view, and the block hasn't been made yet
        if((!self.frame.contains(recognizer.location(in: superview!)) && !madeMyBlockYet)){
            if ((self.currentTitle?.characters.count)! > 0) {
                var newBlock = makeBlock(withLocale: recognizer.location(in: self))
                lastBlockCreated = newBlock
                locationOfView = lastBlockCreated!.center
                madeMyBlockYet = true
            }
        }
        // This code passes the incremental views to InputObject
        if((lastBlockCreated) != nil){
            lastBlockCreated!.center = translationOfTouch + locationOfView!
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
    
    //MARK: Initialization
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "scootBlock:")
        self.addGestureRecognizer(panGestureRecognizer!)
       // self.layer.cornerRadius = 10
    }
}
