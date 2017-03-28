//
//  Paper.swift
//  deskThree
//
//  Created by Cage Johnson on 10/23/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

protocol PaperDelegate {
    func passHeldBlock(sender:Expression)
    func didIncrementMove(_movedView: UIView)
    func didCompleteMove(_movedView: UIView)
    func didEvaluate(forExpression sender: Expression, result: Float)
    func hideTrash()
    func unhideTrash()
}


class Paper: UIImageView, ImageBlockDelegate, ExpressionDelegate {
    
    var delegate: PaperDelegate!
    var images: [ImageBlock]!
    var expressions: [Expression]!
    
    
    func elementWantsSendToInputObject(element:Any){
        delegate.passHeldBlock(sender: element as! Expression)
    }
    
    func didIncrementMove(_movedView: UIView){
        delegate.didIncrementMove(_movedView: _movedView)
    }
    
    func didCompleteMove(_movedView: UIView){
        delegate.didCompleteMove(_movedView: _movedView)
    }
    
    func didEvaluate(forExpression sender: Expression, result: Float){
        delegate.didEvaluate(forExpression: sender, result: result)
    }
    
    func hideTrash(){
        delegate.hideTrash()
    }
    
    func unhideTrash(){
        delegate.unhideTrash()
    }
    
    func stylizeViews(){
        for exp in expressions {
            if let exp = exp as? BlockExpression {
                exp.stylizeViews()
            }
        }
    }
    
    
    func addMathBlockToPage(block: MathBlock){
        block.delegate = self
        expressions.append(block)
    }
    
    func didHoldBlock(sender: MathBlock) {
        delegate.passHeldBlock(sender:sender)
    }
    
    func savePaper(){

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! String
        var filePath = documentsPath.appending("/file.desk")
        NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }
    
    func loadPaper(state: Paper){
        

        
    }
    

    //ImageBlock Delegate Functions
    func fixImageToPage(image: ImageBlock){
        
    }
    
    func freeImageForMovement(image: ImageBlock){
        
    }
    
    func helpMove(imageBlock: ImageBlock, dx: CGFloat, dy: CGFloat) {
        imageBlock.frame.origin.x = imageBlock.frame.origin.x + dx
        imageBlock.frame.origin.y = imageBlock.frame.origin.y + dy

    }
    
    
    func setupDelegateChain(){
        for image in images {
            image.delegate = self
        }
        
        for expression in expressions {
            expression.delegate = self
        }
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(images)
        aCoder.encode(expressions)
    }
    
    //MARK: Initializers
    init() {
        super.init(frame: CGRect(x: 10, y: 10, width: 400, height: 400))
        expressions = [BlockExpression]()
        self.image = UIImage(named: "engineeringPaper2")
        self.isOpaque = false
        images = [ImageBlock]() //creates an array to save the imageblocks
    }
    
    //MARK: setup for loading
    required init(coder unarchiver: NSCoder){
        super.init(coder: unarchiver)!
        images = unarchiver.decodeObject() as! [ImageBlock]!
        for image in images! {
            self.addSubview(image)
        }
        
        expressions = unarchiver.decodeObject() as! [Expression]!
        for expression in expressions {
            self.addSubview(expression)
        }
    }


}
