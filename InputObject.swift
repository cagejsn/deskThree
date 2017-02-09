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
    func hideTrash()
    func unhideTrash()
}

class InputObject: UIView, OutputAreaDelegate {
    
    //MARK: Variables
    var delegate: InputObjectDelegate?
    var newBlock: Block?
    var viewController: DeskViewController?
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        viewController = nil
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: OutputArea Delegate

    func outputAreaDidPassIncrementalMove(movedView: UIView) {
        self.delegate!.didIncrementMove(_movedView: movedView)
       // self.backgroundColor = UIColor.blackColor()
    }
    
    func outputAreaDidPassBlock(lastBlock: Block) {
        delegate!.hideTrash()
        self.delegate!.didCompleteMove(_movedView: lastBlock)
    }
    
    //function below should be rewritten and placed in Expression
    func makeBlockForOutputArea(blockLocation: CGPoint, blockType: Int, blockData: String) -> Block {
        let blockWidth: CGFloat = evaluateStringWidth(textToEvaluate: blockData)
        
        switch blockType {
            case 1:
                newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
                newBlock?.setColor(color: Constants.block.colors.green)
                newBlock?.precedence = Precedence.Number.rawValue
            case 2:
                newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height:Constants.block.height))
                newBlock?.setColor(color: Constants.block.colors.blue)
                
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
                newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2),y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
                newBlock?.setColor(color: Constants.block.colors.gray)
            default:
                //We shouldn't have a default
                newBlock = Block()
            
        }
        newBlock!.text = blockData
        newBlock!.font = UIFont.boldSystemFont(ofSize: Constants.block.fontSize)
        newBlock!.textColor = UIColor.white
        newBlock!.type = blockType
        newBlock?.forBaselineLayout().clipsToBounds = true
        newBlock?.forBaselineLayout().layer.cornerRadius = Constants.block.cornerRadius
        //newBlock?.frame = newBlock!.frame.offsetBy(dx: self.frame.origin.x, dy: self.frame.origin.y)
      //  superview!.addSubview(newBlock!)
        return newBlock!
    }
    
    //function below is the one that is actually used by OutputArea
    func makeBlock(for sender: OutputArea, withLocale blockLocation: CGPoint) -> Block {
        delegate!.unhideTrash()
        let blockWidth: CGFloat = evaluateStringWidth(textToEvaluate: sender.currentTitle!)
        let blockType: Int = sender.typeOfOutputArea!
        let blockData: String = sender.currentTitle!
        
        switch blockType {
        case 1:
            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
            newBlock?.setColor(color: Constants.block.colors.green)
            newBlock?.precedence = Precedence.Number.rawValue
        case 2:
            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height:Constants.block.height))
            newBlock?.setColor(color: Constants.block.colors.blue)
            
            switch blockData {
            case "+":
                newBlock?.precedence = Precedence.Plus.rawValue
                break
            case "-":
                newBlock?.precedence = Precedence.Minus.rawValue
                break
            case "✕":
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
            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2),y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
            newBlock?.setColor(color: Constants.block.colors.gray)
        default:
            //We shouldn't have a default
            newBlock = Block()
            
        }
        
        newBlock!.text = blockData
        newBlock!.font = UIFont.boldSystemFont(ofSize: Constants.block.fontSize)
        newBlock!.textColor = UIColor.white
        newBlock!.type = blockType
        
        newBlock?.frame = newBlock!.frame.offsetBy(dx: sender.frame.origin.x, dy: sender.frame.origin.y)
        newBlock?.frame = newBlock!.frame.offsetBy(dx: self.frame.origin.x , dy: self.frame.origin.y)
        
        
        newBlock?.forBaselineLayout().clipsToBounds = true
        newBlock?.forBaselineLayout().layer.cornerRadius = Constants.block.cornerRadius
        
        superview!.addSubview(newBlock!)
        
        
        return newBlock!
    }
    
    //MARK: Support Methods

    func evaluateStringWidth (textToEvaluate: String) -> CGFloat{
        let font = UIFont.systemFont(ofSize: Constants.block.fontSize)
        let attributes = NSDictionary(object: font, forKey:NSFontAttributeName as NSCopying)
        let sizeOfText = textToEvaluate.size(attributes: (attributes as! [String : AnyObject]))
        return sizeOfText.width + Constants.block.fontWidthPadding;
    }
    
    
}

