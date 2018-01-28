//
//  Paper.swift
//  deskThree
//
//  Created by Cage Johnson on 10/23/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit


// Figure out why we need this
protocol PaperDelegate: NSObjectProtocol {
    func passHeldBlock(sender:Expression, toDestination: ExpressionDestination)
    func didBeginMove(movedView: UIView)
    func didIncrementMove(movedView: UIView)
    func didCompleteMove(movedView: UIView)
    func didEvaluate(forExpression sender: Expression, result: Float)
}

class Paper: UIImageView, UIScrollViewDelegate, ExpressionDelegate {
    
    typealias handler = (MathBlock)->()
    
    var isEdited: Bool = false
    var clipperSession: ClipperSession!
    public weak var delegate: PaperDelegate!
    weak var activeBlock: MathBlock?
    
    //JotUI Properties
    var drawingSession: DrawingSession!
    var drawingView: JotView! {
        get {
           return drawingSession.drawingView
        }
        set(v) {
            drawingSession.drawingView = v
        }
    }
    

    //Persistent Items
    // TODO: MAKE THIS PRIVATE!
    public var expressions: [Expression]!
    private var images: [ImageBlock]!
    private var paperType: SelectedPaperType!

    // JotViewStateProxy Properties
    internal var jotViewStateInkPath: String!
    internal var jotViewStatePlistPath: String!
    
    
    //Handlers for the UIMenuController
    var handlesEditMathBlock: handler!
    var handlesEqualsMathBlock: handler!
    var handlesWRMathBlock: handler!
    
    //UIMenuController display reqs.
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
    

    
    func getPageNumber() -> Int{
        return pageNumber!
    }
    
    func setPageNumber(number: Int){
        pageNumber = number
    }
    
    func edit(){
        if(!isEdited){
            isEdited = true
        }
    }
    
    func getDrawingState() -> JotViewStateProxy {
        return drawingSession.drawingState
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
    
    func elementWantsOptionsMenu(element:Any){
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
        AnalyticsManager.track(.MathBlockMoved)
    }
    
    func didEvaluate(forExpression sender: Expression, result: Float){
        delegate.passHeldBlock(sender: sender, toDestination: .Calculator)
    }
    
    func addMathBlockToPage(block: MathBlock){
        
        block.delegate = self
        expressions.append(block)
        self.addSubview(block)
        showSelectableMathBlockOptions(block)
        AnalyticsManager.track(.MathBlockCreatedFromLasso(block.expressionString))
    }
    
    func setupHandlers(){
        var edit = { block in self.delegate.passHeldBlock(sender: block, toDestination: .MathView)}
        handlesEditMathBlock = edit
        var equals = { block in self.delegate.passHeldBlock(sender: block, toDestination: .Calculator)}
        handlesEqualsMathBlock = equals
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
    
    
    
    func mathBlockEditHandler(){
        guard activeBlock != nil else { return }
        handlesEditMathBlock(activeBlock!)
        
    }
    
    func mathBlockEqualsHandler(){
        guard activeBlock != nil else { return }
        handlesEqualsMathBlock(activeBlock!)
        AnalyticsManager.track(.MathBlockEquals)
    }
    
    func mathBlockWolframHandler(){
        guard activeBlock != nil else { return }
        handlesWRMathBlock(activeBlock!)
        AnalyticsManager.track(.MathBlockWRQuery(activeBlock!.expressionString))
    }
    
    func completedClipperSession(){
        clipperSession = nil
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
        AnalyticsManager.track(.ImageBlockAdded)
    }
    
    func setupDelegateChain(){
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
        drawingSession.endSession()
        
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
    
    func setupDrawingView(withStateDelegate: JotViewStateProxyDelegate){
        if(drawingSession == nil){
        self.drawingSession = DrawingSession(withStateDelegate,self)
        }
        drawingSession.setup()
    }
    
    func subviewDrawingView(){
        drawingSession.subviewDrawingView()
    }
    
    func connectNewDrawingViewToPage(){
        drawingSession.connectNewDrawingViewToPage()
    }
    
    deinit {
        print("deinit")
    }

    //MARK: Initializers
    init(pageNo: Int, workViewPresenter: WorkViewPresenter){
        super.init(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))
        self.drawingSession = DrawingSession(workViewPresenter,self)
        self.pageNumber = pageNo
        setJotPaths()
        expressions = [BlockExpression]()
        self.isOpaque = false
        images = [ImageBlock]()
        drawingSession.setup()
        paperType = .graph
    }
    
    //MARK: setup for loading
    required init(coder unarchiver: NSCoder){
        super.init(coder: unarchiver)!
        isEdited = true
        images = unarchiver.decodeObject() as! [ImageBlock]!
        for image in images! {
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
