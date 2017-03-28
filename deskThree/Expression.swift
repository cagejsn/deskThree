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
    var amtMoved: CGFloat = 0
    var delegate: ExpressionDelegate?
    var parser: Parser
    var expressionString: String = ""
    var longPressGR: UILongPressGestureRecognizer!
    
    //MARK: UIGestureRecognizers
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
        
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
    }
    
    func handleLongPress(){
        delegate?.elementWantsSendToInputObject(element: self)
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

    func getExpressionString() -> String{
        return self.expressionString
    }
    
    //MARK: Support Methods
    static func evaluateStringWidth (textToEvaluate: String) -> CGFloat{
        let font = UIFont.systemFont(ofSize: Constants.block.fontSize)
        let attributes = NSDictionary(object: font, forKey:NSFontAttributeName as NSCopying)
        let sizeOfText = textToEvaluate.size(attributes: (attributes as! [String : AnyObject]))
        return sizeOfText.width + Constants.block.fontWidthPadding;
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(amtMoved)
        aCoder.encode(expressionString)
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
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(Expression.handleLongPress))
        longPressGR.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGR)
    }
    
    required init?(coder unarchiver: NSCoder) {
        self.parser = Parser(functionString: "")
        super.init(coder: unarchiver)
        amtMoved = unarchiver.decodeObject() as! CGFloat!
        expressionString = unarchiver.decodeObject() as! String!
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap")
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(Expression.handleLongPress))
        longPressGR.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGR)
    }
}


