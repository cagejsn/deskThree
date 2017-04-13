//
//  Paper.swift
//  deskThree
//
//  Created by Cage Johnson on 10/23/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel

protocol PaperDelegate {
    func passHeldBlock(sender:Expression)
    func didBeginMove(movedView: UIView)
    func didIncrementMove(movedView: UIView)
    func didCompleteMove(movedView: UIView)
    func didEvaluate(forExpression sender: Expression, result: Float)
}


class Paper: UIImageView, UIScrollViewDelegate, ImageBlockDelegate, ExpressionDelegate, JotViewDelegate, JotViewStateProxyDelegate {
    
    public var delegate: PaperDelegate!
    
    var prevScaleFactor: CGFloat!
    var images: [ImageBlock]!
    var expressions: [Expression]!
    //JotUI Properties
    var drawingView: JotView!
    var pen: Pen!
    var eraser: Eraser!
    var curPen = Constants.pens.pen
    
    // JotViewStateProxy Properties
    var jotViewStateInkPath: String!
    var jotViewStatePlistPath: String!
    var drawingState: JotViewStateProxy!
    
    // Mixpanel initialization
    var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")

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
        // Mixpanel event
        mixpanel.track(event: "Math Block Added to Paper")

        block.delegate = self
        expressions.append(block)
    }
    
    func didHoldBlock(sender: MathBlock) {
        delegate.passHeldBlock(sender:sender)
    }
    
    // Adds an image onto the paper. Used by GKImagePicker Delegate
    func addImageBlock (pickedImage: UIImage){
            let imageBlock: ImageBlock = ImageBlock(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            images?.append(imageBlock) //adds to the array, used to toggle editable
            self.addSubview(imageBlock)
        imageBlock.center = CGPoint (x: self.frame.size.width/4, y: self.frame.size.width/4)
            imageBlock.isUserInteractionEnabled = true
            imageBlock.contentMode = .scaleAspectFit
            imageBlock.setImage(image: pickedImage)
            imageBlock.delegate = self
    }
// NEVER USED
//    func savePaper(){
//
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! String
//        var filePath = documentsPath.appending("/file.desk")
//        NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
//    }


    func reInitDrawingState() {
        drawingState = JotViewStateProxy()
    }
    
    // MARK - UIScrollViewDelegate functions
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Mixpanel event
        mixpanel.track(event: "Gesture: Zoom")
        
        if(prevScaleFactor != nil){
            drawingView.transform = drawingView.transform.scaledBy(x: scrollView.zoomScale/prevScaleFactor, y: scrollView.zoomScale/prevScaleFactor)
        }
        drawingView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
        prevScaleFactor = scrollView.zoomScale
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Mixpanel event
        mixpanel.track(event: "Gesture: Scroll")
        
        drawingView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
    }


    //MARK - ImageBlock Delegate Functions
    func fixImageToPage(image: ImageBlock){
        
    }
    
    func freeImageForMovement(image: ImageBlock){
        
    }
    
    func helpMove(imageBlock: ImageBlock, dx: CGFloat, dy: CGFloat) {
        imageBlock.frame.origin.x = imageBlock.frame.origin.x + dx
        imageBlock.frame.origin.y = imageBlock.frame.origin.y + dy

    }
    
    func setupDrawingView(color: UIColor = UIColor.black){
        pen = Pen(minSize: 0.9, andMaxSize: 1.8, andMinAlpha: 0.6, andMaxAlpha: 0.8)
        pen.color = color
        eraser = Eraser(minSize: 8.0, andMaxSize: 10.0, andMinAlpha: 0.6, andMaxAlpha: 0.8)
        pen.shouldUseVelocity = true
        drawingState = JotViewStateProxy.init(delegate: self)
        drawingView = JotView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44))
        drawingView.delegate = self
        drawingView.isUserInteractionEnabled = true
        // jotView's currentPage property is set which is used for hitTesting
        drawingView.currentPage = self
        // Loading drawingState onto drawingView
        drawingState.loadJotStateAsynchronously(false, with: drawingView.bounds.size, andScale: drawingView.scale, andContext: drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        drawingView.loadState(drawingState)
        drawingView.isUserInteractionEnabled = true
        drawingView.speedUpFPS()
    }
    
    // pragma mark - JotViewDelagate and other JotView stuff
    func togglePenColor() {
        if pen.color == UIColor.black {
            pen.color = UIColor.red
        }else{
            pen.color = UIColor.black
        }
    }
    
    func setPenColor(color: UIColor){
        pen.color = color
    }
    
    func getCurPenColor() -> UIColor {
        return pen.color
    }

    //pragma mark - Helpers
    func activePen() -> Pen {
        switch curPen {
        case .pen:
            return pen
        case .eraser:
            return eraser
        }
    }
    
    func setPen(pen: Constants.pens){
        curPen = pen
    }
    
    func getCurPen() -> Constants.pens {
        return curPen
    }
    
    func togglePen() {
        curPen.next()
    }
    
    func textureForStroke() -> JotBrushTexture! {
        return activePen().textureForStroke()
    }
    
    func stepWidthForStroke() -> CGFloat {
        
        // print(activePen().stepWidthForStroke())
        // return activePen().stepWidthForStroke()
        
        return CGFloat(0.3)
    }
    
    func supportsRotation() -> Bool {
        return activePen().supportsRotation()
    }
    
    func willAddElements(_ elements: [Any]!, to stroke: JotStroke!, fromPreviousElement previousElement: AbstractBezierPathElement!) -> [Any]! {
        return activePen().willAddElements(elements, to: stroke, fromPreviousElement: previousElement)
    }
    
    func willBeginStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> Bool {
        activePen().willBeginStroke(withCoalescedTouch: coalescedTouch, from: touch)
        return true
    }
    
    func willMoveStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen().willMoveStroke(withCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func willEndStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!, shortStrokeEnding: Bool) {
        //noop
    }
    
    func didEndStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen().didEndStroke(withCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func willCancel(_ stroke: JotStroke!, withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen().willCancel(stroke, withCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func didCancel(_ stroke: JotStroke!, withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen().didCancel(stroke, withCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func color(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> UIColor! {
        // hmm?
        //activePen().shouldUseVelocity
        return activePen().color(forCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func width(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        //activePen().shouldUseVelocity
        return activePen().width(forCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func smoothness(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        return activePen().smoothness(forCoalescedTouch: coalescedTouch, from: touch)
    }
    
    
    
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
    
    func saveDrawing(at path: String){
        
        let temp = PathLocator.getTempFolder()
        
        do {
            try FileManager.default.createDirectory(atPath: temp+path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        
        let inkLocation = path+"/ink"+".png"
        let stateLocation = path+"/state"+".plist"
        let thumbLocation = path+"/thumb"+".png"
        
        func doNothing(ink: UIImage? , thumb: UIImage?, state : JotViewImmutableState?) -> Void{
            return;
        }
        
        drawingView.exportImage(to: temp+inkLocation, andThumbnailTo: temp+thumbLocation, andStateTo: temp+stateLocation, andJotState: drawingState, withThumbnailScale: 1.0, onComplete: doNothing)
        jotViewStateInkPath = inkLocation
        jotViewStatePlistPath = stateLocation
        
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(images)
        aCoder.encode(expressions)
        aCoder.encode(jotViewStatePlistPath)
        aCoder.encode(jotViewStateInkPath)
    }
    
    //MARK: Initializers
    init() {
        super.init(frame: CGRect(x: 10, y: 10, width: 400, height: 400))
        expressions = [BlockExpression]()
        self.image = UIImage(named: "engineeringPaper2")
        self.isOpaque = false
        images = [ImageBlock]()
        setupDrawingView()
        
        // Setup pen
        curPen = .pen // Points to pen
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
        
        let temp = PathLocator.getTempFolder()
        
        jotViewStatePlistPath = temp + (unarchiver.decodeObject() as! String)
        jotViewStateInkPath = temp + (unarchiver.decodeObject() as! String)
        setupDrawingView()
        
    }


}
