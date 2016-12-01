//
//  Block.swift
//  EngineeringDesk
//
//  Created by Alejandro Silveyra on 9/8/15.
//  Copyright (c) 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

class Block: UIView  {
    
    //MARK: Variables
    
    @IBOutlet var convexBlock: UIView!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet var convexView: UIView!
    var type: Int?
    var parentExpression: Expression?
    var isAvailableOnRight: Bool = true
    var isAvailableOnLeft: Bool = true
    var precedence: Int?
    var parent: Block?
    var leftChild: Block?
    var rightChild: Block?
    var innerChild: Block?

    
    //MARK: Initialization
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    func xibSetup() {
       convexBlock = loadViewFromNib()
        
        //custom color for the symbol blocks can be adjusted here: current color name "seagreen"
       convexBlock.backgroundColor = Constants.block.colors.def
        // use bounds not frame or it'll be offset
        convexBlock.frame = bounds
        // Make the view stretch with containing view
        convexBlock.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth];
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(convexBlock)
        convexBlock.backgroundColor = UIColor.green
        for element in convexBlock.subviews {
            element.layer.cornerRadius = 10;
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName:"Block", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    required init ?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    //MARK: Support Methods
    func canLink(aBlockToAccomodate: Block) -> Bool{
        switch aBlockToAccomodate.type! {
            case TypeOfBlock.Number.rawValue:
                switch self.type! {
                    case TypeOfBlock.Number.rawValue:
                        return false
                    case TypeOfBlock.Operator.rawValue:
                        return true
                    case TypeOfBlock.Symbol.rawValue:
                        return true
                    case TypeOfBlock.ExtraEquation.rawValue:
                        return true
                    default:
                        break
                }
            case TypeOfBlock.Operator.rawValue:
                switch self.type! {
                    case TypeOfBlock.Number.rawValue:
                        return true
                    case TypeOfBlock.Operator.rawValue:
                        return false
                    case TypeOfBlock.Symbol.rawValue:
                        return true
                    case TypeOfBlock.ExtraEquation.rawValue:
                        return true
                    default:
                        break
                }
            case TypeOfBlock.Symbol.rawValue:
                switch self.type! {
                    case TypeOfBlock.Number.rawValue:
                        return false
                    case TypeOfBlock.Operator.rawValue:
                        return true
                    case TypeOfBlock.Symbol.rawValue:
                        return true
                    case TypeOfBlock.ExtraEquation.rawValue:
                        return true
                    default:
                        break
                }
            case TypeOfBlock.ExtraEquation.rawValue:
                switch self.type! {
                    case TypeOfBlock.Number.rawValue:
                        return true
                    case TypeOfBlock.Operator.rawValue:
                        return true
                    case TypeOfBlock.Symbol.rawValue:
                        return true
                    case TypeOfBlock.ExtraEquation.rawValue:
                        return true
                    default:
                        break
                }
            default:
                break
        }
        return false
    }
    
    func removeDummyBlocks(){
        
        
        if(leftChild != nil){
            if(leftChild!.type == TypeOfBlock.Glow.rawValue){
                leftChild!.isHidden = true
                leftChild = nil
            }else{
                leftChild!.removeDummyBlocks()
            }
        }
        
        if(rightChild != nil){
            if(rightChild!.type == TypeOfBlock.Glow.rawValue){
                rightChild!.isHidden = true
                rightChild = nil
            }else{
                rightChild!.removeDummyBlocks()
            }
        }
    }
    
    func makeAListOfSpotsBelowMe(aBlockToAccomodate: Block) -> [Block]{
        
        var glowBlocks: [Block] = []
        if(leftChild != nil) {
            glowBlocks.append(contentsOf: leftChild!.makeAListOfSpotsBelowMe(aBlockToAccomodate: aBlockToAccomodate))
        }
        else {
            if(isAvailableOnLeft && aBlockToAccomodate.isAvailableOnRight) {
                if(canLink(aBlockToAccomodate: aBlockToAccomodate)){
                    
                    var newFrameSize: CGRect
                    if(aBlockToAccomodate.parentExpression != nil){
                     newFrameSize = aBlockToAccomodate.parentExpression!.frame
                    } else { newFrameSize = aBlockToAccomodate.frame }
                    
                    
                    self.leftChild = Block(frame: CGRect(x: -newFrameSize.width, y: 0, width: newFrameSize.width, height: newFrameSize.height))
                    //self.addSubview(leftChild!)
                   // leftChild!.frame = CGRectOffset(leftChild!.frame, self.frame.origin.x, 0)
                    leftChild!.type = TypeOfBlock.Glow.rawValue
                    leftChild!.parent = self
                    glowBlocks.append(leftChild!)
                }
            }
        }
        
        if(rightChild != nil) {
            glowBlocks.append(contentsOf: rightChild!.makeAListOfSpotsBelowMe(aBlockToAccomodate: aBlockToAccomodate))
        }
        else {
            if(isAvailableOnRight && aBlockToAccomodate.isAvailableOnLeft){
                if(canLink(aBlockToAccomodate: aBlockToAccomodate)){
                
                    var newFrameSize: CGRect?
                    if(aBlockToAccomodate.parentExpression != nil){
                        newFrameSize = aBlockToAccomodate.parentExpression!.frame
                    } else { newFrameSize = aBlockToAccomodate.frame }
                    
                    
                    self.rightChild = Block(frame: CGRect(x:superview!.frame.width, y:0, width:newFrameSize!.width, height:newFrameSize!.height))
                   // self.rightChild = Block(frame: CGRectMake(self.frame.width, 0, newFrameSize!.width, newFrameSize!.height))
                    
                   // self.addSubview(rightChild!)
                    //rightChild!.frame = CGRectOffset(rightChild!.frame, 2 * self.frame.origin.x, 0)
                    rightChild!.type = TypeOfBlock.Glow.rawValue
                    rightChild!.parent = self
                    glowBlocks.append(rightChild!)
                }
            }
        }
        
        if(self.type == TypeOfBlock.Special.rawValue){
            if(self.innerChild != nil){
                glowBlocks.append(contentsOf: self.innerChild!.makeAListOfSpotsBelowMe(aBlockToAccomodate: aBlockToAccomodate))
            }
            else {
                if(self.canLink(aBlockToAccomodate: aBlockToAccomodate)){
                    self.innerChild = Block(frame: self.frame.insetBy(dx: 10, dy: 10))
                    self.addSubview(innerChild!)
                    glowBlocks.append(innerChild!)
                }
            }
        }
        //return a list of the nodes
        return glowBlocks
    }
    
    func getValue() -> String {
        return self.blockLabel.text!
    }
    
    func setColor(color : UIColor) {
        convexBlock.backgroundColor = color
    }
}
