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

enum ExpressionDestination {
    case MathView
    case Calculator
    case Wolfram
}


// Figure out why we need this
protocol PaperDelegate: NSObjectProtocol {
    func passHeldBlock(sender:Expression, toDestination: ExpressionDestination)
    func didBeginMove(movedView: UIView)
    func didIncrementMove(movedView: UIView)
    func didCompleteMove(movedView: UIView)
    func didEvaluate(forExpression sender: Expression, result: Float)
}


class Paper: UIImageView, UIScrollViewDelegate, ImageBlockDelegate, ExpressionDelegate {
    
    typealias handler = (MathBlock)->()
    
    var clipperSession: ClipperSession!
    
    public weak var delegate: PaperDelegate!
    // TODO: MAKE THIS PRIVATE!
    public var expressions: [Expression]!
    
    private var prevScaleFactor: CGFloat!
    private var images: [ImageBlock]!
    
    private var paperType: SelectedPaperType!
    //JotUI Properties
    var drawingView: JotView!
    
    var handlesEditMathBlock: handler!
    var handlesEqualsMathBlock: handler!
    var handlesWRMathBlock: handler!
    
    // JotViewStateProxy Properties
    internal var jotViewStateInkPath: String!
    internal var jotViewStatePlistPath: String!
    private var drawingState: JotViewStateProxy!
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func resignFirstResponder() -> Bool {
        activeBlock = nil
        return super.resignFirstResponder()
    }
    
    
    
    private var pageNumber: Int?
    
    #if !DEBUG
        var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif
    
    func getPageNumber() -> Int{
        return pageNumber!
    }
    
    func setPageNumber(number: Int){
        pageNumber = number
    }
    
    func getDrawingState() -> JotViewStateProxy{
        return drawingState
    }

    func setBackground(to: SelectedPaperType){
        let image: UIImage!
        switch to {
        case .graph:
            image = UIImage(named: "simpleGraphPaper")
            paperType = .graph
        case .engineering:
            image = UIImage(named: "engineeringPaper")
            paperType = .engineering
        case .lined:
            image = UIImage(named: "linedPaper")
            paperType = .lined  
        default:
            image = UIImage(named: "apple")
        }
        self.image = image
    }
    
    
    func elementWantsSendToInputObject(element:Any){
        
        showSelectableMathBlockOptions(element as! MathBlock)
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
        showSelectableMathBlockOptions(block)
    }
    
    func setupHandlers(){
        var edit = { block in self.delegate.passHeldBlock(sender: block, toDestination: .MathView)}
        handlesEditMathBlock = edit
        var wr = { block in self.delegate.passHeldBlock(sender: block, toDestination: .Wolfram)}
        handlesWRMathBlock = wr
    }
    
    func showSelectableMathBlockOptions(_ block: MathBlock){
        activeBlock = block
        setupHandlers()
        becomeFirstResponder()
        var selectActionMenu: UIMenuController = UIMenuController.shared
        selectActionMenu.arrowDirection = .down
        selectActionMenu.setTargetRect(block.frame, in: self)
        
        
        var selectableActionEdit = UIMenuItem(title: "edit", action: #selector(Paper.mathBlockEditHandler))
        var selectableActionEquals = UIMenuItem(title: "=", action: #selector(Paper.mathBlockEqualsHandler))
        var selectableActionWolfram = UIMenuItem(title: "wr", action: #selector(Paper.mathBlockWolframHandler))
       
        selectActionMenu.menuItems = [selectableActionEdit,selectableActionEquals,selectableActionWolfram]
        selectActionMenu.setMenuVisible(true, animated: true)
    }
    
    weak var activeBlock: MathBlock?
    
    func mathBlockEditHandler(){
        guard activeBlock != nil else { return }
        handlesEditMathBlock(activeBlock!)
    }
    
    func mathBlockEqualsHandler(){
        guard activeBlock != nil else { return }
        handlesEqualsMathBlock(activeBlock!)
    }
    
    func mathBlockWolframHandler(){
        guard activeBlock != nil else { return }
        handlesWRMathBlock(activeBlock!)
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
    
    func setupDrawingView(withStateDelegate delegate:JotViewStateProxyDelegate){

        drawingState = JotViewStateProxy.init(delegate: delegate as! NSObjectProtocol & JotViewStateProxyDelegate)
        drawingView = JotView(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))

        drawingView.isUserInteractionEnabled = true
        // jotView's currentPage property is set which is used for hitTesting
        drawingView.currentPage = self
        // Loading drawingState onto drawingView
        drawingState.loadJotStateAsynchronously(false, with: drawingView.bounds.size, andScale: drawingView.scale, andContext: drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        drawingView.loadState(drawingState)
        drawingView.isUserInteractionEnabled = true
        drawingView.speedUpFPS()
       
        
        drawingView.transform = drawingView.transform.scaledBy(x: 0.6, y: 0.6)
    }
    
    func subviewDrawingView() {
        superview?.superview?.insertSubview(drawingView, at: 1)
        drawingView.delegate = self.superview as! WorkView!
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
    
    
    // Method to remove an expression or image. Can be extended to support any uiview sitting
    // on top of paper
    func removeObject(object: UIView) {
        object.removeFromSuperview()
        if expressions.removeObject(object: object) {
            return
        }
        
        else if images.removeObject(object: object) {
            return
        }
        // Should not get here
    }
    
    func removePage(){
        drawingView.deleteAssets()
        drawingView.invalidate()
        drawingView = nil
        
        drawingState.isForgetful = true
        drawingState.unload()
        drawingState = nil

        for expression in expressions {
            expression.removeFromSuperview()
        }
        expressions.removeAll()
        for image in images {
            image.removeFromSuperview()
        }
        images.removeAll()
        self.removeFromSuperview()
    }

    // NOTE: we do not encode and decode jotListStatePath and jotListPlistPath
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(images)
        aCoder.encode(expressions)
        aCoder.encode(paperType.rawValue, forKey: "paperType")
        aCoder.encode(pageNumber, forKey: "pageNumber")
        aCoder.encode(jotViewStatePlistPath)
        aCoder.encode(jotViewStateInkPath)
    }
    
    func setJotPaths(){
        let pageFolderPath = "/page" + String(pageNumber!)
        
        let inkLocation   = pageFolderPath+"/ink.png"
        let stateLocation = pageFolderPath+"/state.plist"
        let thumbLocation = pageFolderPath+"/thumb.png"
   
        jotViewStatePlistPath = stateLocation
        jotViewStateInkPath = inkLocation
    }
    
    deinit {
        print("deinit")
    }

    //MARK: Initializers
    init(pageNo: Int, workViewPresenter: WorkViewPresenter ){
        
        super.init(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))
        self.pageNumber = pageNo
        setJotPaths()
        expressions = [BlockExpression]()
        //self.image = UIImage(named: "simpleGraphPaper")
        //  self.contentMode = .scaleToFill
        self.isOpaque = false
        images = [ImageBlock]()
        setupDrawingView(withStateDelegate: workViewPresenter)
        paperType = .graph
        
    }
    
    //MARK: setup for loading
    required init(coder unarchiver: NSCoder){
        super.init(coder: unarchiver)!
        images = unarchiver.decodeObject() as! [ImageBlock]!
        for image in images! {
            image.delegate = self
            self.addSubview(image)
        }
        
        expressions = unarchiver.decodeObject() as! [Expression]!
        for expression in expressions {
            expression.delegate = self
            self.addSubview(expression)
        }
       
        //paperType = unarchiver.decodeData() as! SelectedPaperType
        let int = unarchiver.decodeInteger(forKey: "paperType")
        paperType = SelectedPaperType(rawValue: int)
        setBackground(to: paperType)
        
        let pageNumberMaybe = unarchiver.decodeObject(forKey: "pageNumber")
        if let pgNumber = pageNumberMaybe as! Int? {
            self.pageNumber = pgNumber
        }
    
        jotViewStatePlistPath = unarchiver.decodeObject() as! String!
        jotViewStateInkPath = unarchiver.decodeObject() as! String!
    }
}
