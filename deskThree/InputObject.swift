//
//  Mosaic.swift
//  EngineeringDesk
//
//  Created by Cage Johnson on 8/2/15.
//  Copyright (c) 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

protocol InputObjectDelegate{
    func didCompleteMove(_movedView: UIView)
    func didIncrementMove(_movedView: UIView)
}

class InputObject: UIView, OutputAreaDelegate {
    
    //MARK: Variables
    var delegate: InputObjectDelegate?
    var newBlock: Block?
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: OutputArea Delegate

    func outputAreaDidPassIncrementalMove(movedView: UIView) {
        self.delegate!.didIncrementMove(movedView)
       // self.backgroundColor = UIColor.blackColor()
    }
    
    func outputAreaDidPassBlock(lastBlock: Block) {
        self.delegate!.didCompleteMove(lastBlock)
    }
    
    func makeBlockForOutputArea(blockLocation: CGPoint, blockType: Int, blockData: String) -> Block {
        let blockWidth: CGFloat = evaluateStringWidth(blockData)
        
        switch blockType {
            case 1:
                newBlock = Block(frame: CGRectMake(blockLocation.x - (blockWidth/2), blockLocation.y - 50, blockWidth, Constants.block.height))
                newBlock?.setColor(Constants.block.colors.green)
                newBlock?.precedence = Precedence.Number.rawValue
            case 2:
                newBlock = Block(frame: CGRectMake(blockLocation.x - (blockWidth/2), blockLocation.y - 50, blockWidth, Constants.block.height))
                newBlock?.setColor(Constants.block.colors.blue)
                
                switch blockData {
                    case "+":
                        newBlock?.precedence = Precedence.Plus.rawValue
                        break
                    case "-":
                        newBlock?.precedence = Precedence.Minus.rawValue
                        break
                    case "x":
                        newBlock?.precedence = Precedence.Multiply.rawValue
                        break
                    case "÷":
                        newBlock?.precedence = Precedence.Divide.rawValue
                        break
                    case "√":
                        newBlock?.precedence = Precedence.Multiply.rawValue
                        break
                    case "^":
                        newBlock?.precedence = Precedence.Multiply.rawValue
                        break
                    default:
                        break
                }
            case 3:
                newBlock = Block(frame: CGRectMake(blockLocation.x - (blockWidth/2),blockLocation.y - 50, blockWidth, Constants.block.height))
                newBlock?.setColor(Constants.block.colors.gray)
            default:
                //We shouldn't have a default
                newBlock = Block()
            
        }
        
        newBlock!.blockLabel.text = blockData
        newBlock!.blockLabel.font = UIFont.boldSystemFontOfSize(Constants.block.fontSize)
        newBlock!.blockLabel.textColor = UIColor.whiteColor()
        newBlock!.type = blockType
        newBlock!.frame.offsetInPlace(dx: self.frame.origin.x , dy: self.frame.origin.y)
        newBlock?.viewForBaselineLayout().clipsToBounds = true
        newBlock?.viewForBaselineLayout().layer.cornerRadius = Constants.block.cornerRadius
       
        superview!.addSubview(newBlock!)
   
        
        return newBlock!
        
    }
    
    
    //MARK: Support Methods

    func evaluateStringWidth (textToEvaluate: String) -> CGFloat{
        let font = UIFont.systemFontOfSize(Constants.block.fontSize)
        let attributes = NSDictionary(object: font, forKey:NSFontAttributeName)
        let sizeOfText = textToEvaluate.sizeWithAttributes((attributes as! [String : AnyObject]))
        return sizeOfText.width + Constants.block.fontWidthPadding;
    }
    
    
}

