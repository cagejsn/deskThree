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
    func didBeginMove(movedView: UIView)
    func didIncrementMove(movedView: UIView)
    func didCompleteMove(movedView: UIView)
    func didEvaluate(forExpression sender: Expression, result: Float)
}


class Paper: UIImageView, ImageBlockDelegate, ExpressionDelegate, JotViewStateProxyDelegate {
    
    var delegate: PaperDelegate!
    var images: [ImageBlock]!
    var expressions: [Expression]!
    var drawingView: JotView!
    var drawingState: JotViewStateProxy!
    var jotViewStateInkPath: String!
    var jotViewStatePlistPath: String!
    
    func elementWantsSendToInputObject(element:Any){
        delegate.passHeldBlock(sender: element as! Expression)
    }
    
    func didBeginMove(movedView: UIView){
        delegate.didBeginMove(movedView: movedView)
    }

    func didIncrementMove(movedView: UIView){
        delegate.didIncrementMove(movedView: movedView)
    }
    
    func didCompleteMove(movedView: UIView){
        delegate.didCompleteMove(movedView: movedView)
    }
    
    func didEvaluate(forExpression sender: Expression, result: Float){
        delegate.didEvaluate(forExpression: sender, result: result)
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


    func reInitDrawingState() {
        drawingState.isForgetful = true
        drawingState = JotViewStateProxy()
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
    
//    func setupDrawingView(){
//        
//        
//        pen = Pen(minSize: 0.9, andMaxSize: 1.8, andMinAlpha: 0.6, andMaxAlpha: 0.8)
//        eraser = Eraser(minSize: 8.0, andMaxSize: 10.0, andMinAlpha: 0.6, andMaxAlpha: 0.8)
//        pen.shouldUseVelocity = true
//        //  UserDefaults.standard.set("marker", forKey: kSelectedBruch)
//        workView.currentPage.drawingView = JotView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44))
//        jotView.delegate = self
//        jotView.isUserInteractionEnabled = true
//        workView.currentPage.drawingState.loadJotStateAsynchronously(false, with: jotView.bounds.size, andScale: jotView.scale, andContext: jotView.context, andBufferManager: JotBufferManager.sharedInstance())
//        jotView.loadState(workView.currentPage.drawingState)
//        // inserting jotView right below toolbar
//        self.view.insertSubview(jotView, at: 1)
//        jotView.isUserInteractionEnabled = false
//        jotView.speedUpFPS()
//    }

    
    //pragma mark - JotViewStateProxyDelegate
    
    func documentDir() -> String {
        let userDocumentsPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return userDocumentsPaths.first!
    }
    
    func didLoadState(_ state: JotViewStateProxy!) {
        
    }
    
    func didUnloadState(_ state: JotViewStateProxy!) {
        
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
        drawingState = JotViewStateProxy()
    }
    
    //MARK: setup for loading
    required init(coder unarchiver: NSCoder){
        super.init(coder: unarchiver)!
        images = unarchiver.decodeObject() as! [ImageBlock]!
        for image in images! {
            self.addSubview(image)
            image.delegate = self
        }
        
        expressions = unarchiver.decodeObject() as! [Expression]!
        for expression in expressions {
            self.addSubview(expression)
        }
    }


}
