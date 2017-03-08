//
//  Expression.swift
//  EngineeringDesk
//
//  Created by Alejandro Silveyra on 9/8/15.
//  Copyright (c) 2015 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

protocol ExpressionDelegate {
    func elementWantsSendToInputObject(element:Any)
    func didIncrementMove(_movedView: UIView)
    func didCompleteMove(_movedView: UIView)
    func didEvaluate(forExpression sender: Expression, result: Float)
    func hideTrash()
    func unhideTrash()
}

class Expression: UIView, UIGestureRecognizerDelegate {
    
    //MARK: Variables
//    var isDisplayingSpots: Bool = false
//    var dummyViews: [Block] = []
    var amtMoved: CGFloat = 0
//    var rootBlock: Block
    var delegate: ExpressionDelegate?
    var parser: Parser
    var expressionString: String = ""
//    var longPressGR: UILongPressGestureRecognizer!
    
    //MARK: UIGestureRecognizers
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    
  


//    static func makeBlock(blockLocation: CGPoint, blockType: Int, blockData: String) -> Block {
//        let blockWidth: CGFloat = evaluateStringWidth(textToEvaluate: blockData)
//        var newBlock: Block!
//        switch blockType {
//        case 1:
//            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
//            newBlock?.setColor(color: Constants.block.colors.green)
//            newBlock?.precedence = Precedence.Number.rawValue
//        case 2:
//            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2), y:blockLocation.y - 50, width:blockWidth, height:Constants.block.height))
//            newBlock?.setColor(color: Constants.block.colors.blue)
//            
//            switch blockData {
//            case "+":
//                newBlock?.precedence = Precedence.Plus.rawValue
//                break
//            case "-":
//                newBlock?.precedence = Precedence.Minus.rawValue
//                break
//            case "x":
//                newBlock?.precedence = Precedence.Multiply.rawValue
//                break
//            case "÷":
//                newBlock?.precedence = Precedence.Divide.rawValue
//                break
//            case "√":
//                newBlock?.precedence = Precedence.Multiply.rawValue
//                break
//            case "^":
//                newBlock?.precedence = Precedence.Multiply.rawValue
//                break
//            default:
//                break
//            }
//        case 3:
//            newBlock = Block(frame: CGRect(x:blockLocation.x - (blockWidth/2),y:blockLocation.y - 50, width:blockWidth, height: Constants.block.height))
//            newBlock?.setColor(color: Constants.block.colors.gray)
//        default:
//            //We shouldn't have a default
//            newBlock = Block()
//            
//        }
//        newBlock!.text = blockData
//        newBlock!.font = UIFont.boldSystemFont(ofSize: Constants.block.fontSize)
//        newBlock!.textColor = UIColor.white
//        newBlock!.type = blockType
//        newBlock?.forBaselineLayout().clipsToBounds = true
//        newBlock?.forBaselineLayout().layer.cornerRadius = Constants.block.cornerRadius
//        //newBlock?.frame = newBlock!.frame.offsetBy(dx: self.frame.origin.x, dy: self.frame.origin.y)
//        //  superview!.addSubview(newBlock!)
//        return newBlock!
//    }

    
    
    
    
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
//        aCoder.encode(rootBlock)
        //aCoder.encode(parser)
    }
    
    /* MARK: Touch Events */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview!.bringSubview(toFront: self)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate!.unhideTrash()
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
        /* checking if over trashBin */
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.delegate!.didCompleteMove(_movedView: self)
        self.delegate!.hideTrash()
    }
    
//    func handleLongPress(){
//        delegate?.elementWantsSendToInputObject(element: self)
//    }
    
    //MARK: Gesture Recognizer Methods
    func handleDoubleTap(){
        print(self.expressionString)
        parser.parserSetFunction(functionString: expressionString)
        do {
            try parser.parserPlot(start: 1, end: 2, totalSteps: 1)

        } catch MathError.missingOperand {
            print(parser.getError())
            
        } catch let error {
            print(error.localizedDescription)
        }
        if parser.getError() == "" {
            delegate!.didEvaluate(forExpression: self, result: Float(parser.getY()[0]))

        }
        
        
//        if(ETree.canBeEvaluated(node: self.rootBlock)){
//            delegate!.didEvaluate(forExpression: self, result: Float(ETree.evaluate(node: self.rootBlock)))
//
//        }
    }
    
    //MARK: Support Methods
    func isMoveInsideBound (x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) -> Bool {
        if (x >= (superview!.frame.origin.x - width) && y >= superview!.frame.origin.y - height) {
            if (x <= Constants.dimensions.Paper.width && y <= Constants.dimensions.Paper.height - 44) {
                return true
            }
        }
        return false
    }
    
//    /// tells is one block is close to another
//    func isNear(incomingFrame: CGRect) -> Bool{
//        if(self.frame.insetBy(dx: -60, dy: -60).intersects(incomingFrame)){
//            return true
//        }
//        return false
//    }
    
//    //this function has a long way to go
//    func findAndShowAvailableSpots(_movedView: UIView){
//        //first find out what kind of View it is
//        if let block = _movedView as? Block {
//            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: block)
//        }
//        if let expression = _movedView as? Expression {
//            dummyViews = self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: ETree.getLeftestNode(root: expression.rootBlock))
//            
//            dummyViews.append(contentsOf: self.rootBlock.makeAListOfSpotsBelowMe(aBlockToAccomodate: ETree.getRightestNode(root: expression.rootBlock)))
//        }
//        
//        for dummy in dummyViews {
//            addSubview(dummy)
//            dummy.isHidden = false
//            dummy.layer.borderWidth = 1.0
//        }
//        isDisplayingSpots = true
//    }
//    
//    func hideSpots(){
//        self.rootBlock.removeDummyBlocks() //set revert to nil for real block
//        self.dummyViews.removeAll() //clearout global dummy list
//        isDisplayingSpots = false
//    }
    
//    func animateMove(movedView: UIView, dummy: UIView) {
//        
//        CATransaction.begin()
//        CATransaction.setAnimationDuration(0.5)
//        CATransaction.setCompletionBlock({
//            movedView.isUserInteractionEnabled = true
//        })
//        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
//        let finalPosition: CGPoint = dummy.frame.origin
//        
//        positionAnimation.duration = 0.5
//        positionAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
//        positionAnimation.fromValue = NSValue(cgPoint:movedView.center)
//        positionAnimation.toValue = NSValue(cgPoint: dummy.center)
//        positionAnimation.beginTime = CACurrentMediaTime()
//        positionAnimation.fillMode = kCAFillModeForwards
//        positionAnimation.isRemovedOnCompletion = false
//        
//        movedView.layer.add(positionAnimation, forKey: "positionAnimation")
//       // movedView.layer.position = finalPosition
//        
//        CATransaction.commit()
//    }
    
    
//    //unwritten function
//    func mergeExpressions(incomingExpression: Expression, side: String) {
//        
//        var incomingRootBlock = incomingExpression.rootBlock
//        
//        switch (side) {
//            
//            case "left":
//                ETree.addLeft(persistentBlock: rootBlock, lesserBlock: incomingRootBlock)
//                break
//            case "right":
//                ETree.addRight(lastingBlock: rootBlock, lesserBlock: incomingRootBlock)
//                break
//            case "inner":
//                break
//        
//            default:
//                break
//        }
//
//        
//            //if the incoming expression is of a higher precedence, then make its root the new root.
//            //the ETree should have been rearranged properly in the previous functions
//            if(incomingExpression.rootBlock.precedence! > rootBlock.precedence!){
//                self.rootBlock = incomingExpression.rootBlock
//            }
//            ETree.setParentGroup(node: self.rootBlock, parentGroup: self)
//            ETree.printCurrentTree(root: self.rootBlock)
//        
//            //Expressions aren't ready because they number blocks don't have a
//            //Double Value yet
//        /*
// 
//        if(ETree.canBeEvaluated(self.rootBlock)){
//             print( ETree.evaluate(self.rootBlock))
//        }
// 
//        */
//        
//    }
    func getExpressionString() -> String{
        return self.expressionString
    }
//
//    /* in order traversal of tree, printing each value along the way */
//    private func getExpressionStringHelper (root : Block) {
//        if(root.leftChild != nil){
//            getExpressionStringHelper(root: root.leftChild!)
//        }
//        functionString += root.getValue()
//        if (root.rightChild != nil){
//            getExpressionStringHelper(root: root.rightChild!)
//        }
//    }
    
    
    //MARK: Support Methods
    static func evaluateStringWidth (textToEvaluate: String) -> CGFloat{
        let font = UIFont.systemFont(ofSize: Constants.block.fontSize)
        let attributes = NSDictionary(object: font, forKey:NSFontAttributeName as NSCopying)
        let sizeOfText = textToEvaluate.size(attributes: (attributes as! [String : AnyObject]))
        return sizeOfText.width + Constants.block.fontWidthPadding;
    }
    
    //MARK: Initialization
    override init(frame: CGRect){
//        rootBlock = firstVal
//        var newFrame: CGRect = CGRect(origin: firstVal.frame.origin, size: firstVal.frame.size)
        parser = Parser(functionString: "")
        super.init(frame: frame)
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap")
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
        
        
    }
    
    required init?(coder unarchiver: NSCoder) {
//        self.rootBlock = unarchiver.decodeObject() as! Block
//        self.parser = Parser(functionString: "")
//        super.init(coder: unarchiver)
        fatalError("init(coder:) has not been implemented")
    }
}


