//
//  Paper.swift
//  deskThree
//
//  Created by Cage Johnson on 10/23/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit
#if !DEBUG
    import Mixpanel
#endif

// Figure out why we need this
protocol PaperDelegate {
    func passHeldBlock(sender:Expression)
    func didBeginMove(movedView: UIView)
    func didIncrementMove(movedView: UIView)
    func didCompleteMove(movedView: UIView)
    func didEvaluate(forExpression sender: Expression, result: Float)
}


class Paper: UIImageView, UIScrollViewDelegate, ImageBlockDelegate, ExpressionDelegate, JotViewStateProxyDelegate {
    
    public var delegate: PaperDelegate!
    // TODO: MAKE THIS PRIVATE!
    public var expressions: [Expression]!
    
    private var prevScaleFactor: CGFloat!
    private var images: [ImageBlock]!
    //JotUI Properties
    var drawingView: JotView!
    
    // JotViewStateProxy Properties
    internal var jotViewStateInkPath: String!
    internal var jotViewStatePlistPath: String!
    private var drawingState: JotViewStateProxy!
    
    #if !DEBUG
        var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif

    func setBackground(to: SelectedPaperType){
        let image: UIImage!
        switch to {
        case .graph:
            image = UIImage(named: "simpleGraphPaper")
        case .engineering:
            image = UIImage(named: "engineeringPaper")
        case .lined:
            image = UIImage(named: "linedPaper")
        default:
            image = UIImage(named: "apple")
        }
        self.image = image
    }
    
    
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
        #if !DEBUG
            mixpanel.track(event: "Math Block Added to Paper")
        #endif

        block.delegate = self
        expressions.append(block)
        self.addSubview(block)
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


    
    // MARK - UIScrollViewDelegate functions
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        #if !DEBUG
            mixpanel.track(event: "Gesture: Zoom")
        #endif
        
        if(prevScaleFactor != nil){
            drawingView.transform = drawingView.transform.scaledBy(x: scrollView.zoomScale/prevScaleFactor, y: scrollView.zoomScale/prevScaleFactor)
        }
        drawingView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
        prevScaleFactor = scrollView.zoomScale
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        #if !DEBUG
            mixpanel.track(event: "Gesture: Scroll")
        #endif
        
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
    
    func setupDrawingView(){

        drawingState = JotViewStateProxy.init(delegate: self)
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
        drawingView = JotView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44))
        }
        else {
            drawingView = JotView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width - 44))
        }
        drawingView.isUserInteractionEnabled = true
        // jotView's currentPage property is set which is used for hitTesting
        drawingView.currentPage = self
        // Loading drawingState onto drawingView
        drawingState.loadJotStateAsynchronously(false, with: drawingView.bounds.size, andScale: drawingView.scale, andContext: drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        drawingView.loadState(drawingState)
        drawingView.isUserInteractionEnabled = true
        drawingView.speedUpFPS()
    }
    
    func subviewDrawingView() {
        superview?.superview?.insertSubview(drawingView, at: 1)
        drawingView.delegate = self.superview as! WorkView
    }
    
    func clearDrawing() {
        // The backing texture does not get updated when we clear the JotViewGLContext. Hence,
        // We just load up a whole new state to get a cleared backing texture. I know, it is
        // hacky. I challenge you to find a cleaner way to do it in JotViewState's background Texture itself        
        drawingState.isForgetful = true
        drawingState = JotViewStateProxy()
        drawingState.loadJotStateAsynchronously(false, with: drawingView.bounds.size, andScale: drawingView.scale, andContext: drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        drawingView.loadState(drawingState)
        drawingView.clear(true)
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
        
        
        let inkLocation   = path+"/ink.png"
        let stateLocation = path+"/state.plist"
        let thumbLocation = path+"/thumb.png"
        
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
//        aCoder.encode(jotViewStatePlistPath)
//        aCoder.encode(jotViewStateInkPath)
    }
    
    //MARK: Initializers
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))
        expressions = [BlockExpression]()
        //self.image = UIImage(named: "simpleGraphPaper")
      //  self.contentMode = .scaleToFill
        self.isOpaque = false
        images = [ImageBlock]()
        setupDrawingView()
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
       
//        let temp = PathLocator.getTempFolder()
//
//        jotViewStatePlistPath = temp + (unarchiver.decodeObject() as! String)
//        jotViewStateInkPath = temp + (unarchiver.decodeObject() as! String)        
    }


}
