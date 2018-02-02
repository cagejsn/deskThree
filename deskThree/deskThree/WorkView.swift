//
//  WorkView.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

protocol WorkViewDelegate: NSObjectProtocol {
    func intersectsWithTrash(justMovedBlock: UIView)->Bool
    func unhideTrash()
    func hideTrash()
    func sendingToInputObject(for element: Any, toDestination: ExpressionDestination)
    func displayErrorInViewController(title: String, description: String)
}

class WorkView: UIScrollView, InputObjectDelegate, PaperDelegate, PageAndDrawingDelegate, JotViewDelegate {
    
    public weak var customDelegate: WorkViewDelegate!
    private var longPressGR: UILongPressGestureRecognizer!
    
    // state information for what is happening in Paper and its drawing view
    private var cornerPageLabel: UILabel!
    private var pen: Pen!
    private var originalMinSize: CGFloat = 1.5
    private var originalMaxSize: CGFloat = 3.5
    private var eraser: Eraser!
    private var curPen = Constants.pens.pen
    private var selectedPaperType: SelectedPaperType = .graph
    
    weak var workViewPresenter: WorkViewPresenter?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupPageNumberSystem()
    }
    
    //MARK: Data Flow
    func passHeldBlock(sender: Expression, toDestination: ExpressionDestination) {
        customDelegate.sendingToInputObject(for: sender, toDestination: toDestination)
    }
    
    func receiveNewMathBlock(_ createdMathBlock: MathBlock){
        let currentPage = workViewPresenter!.currentPage!
        currentPage.addMathBlockToPage(block: createdMathBlock)
        didIncrementMove(movedView: createdMathBlock)
        let change = PaperChange.MovedBlock
        workViewPresenter!.blockWasMoved(change)
    }
    
    // Do not call this when superview is nil
    func setupPageNumberSystem(){
        if superview == nil {
            return
        }
        cornerPageLabel = UILabel()
        cornerPageLabel.textAlignment = .center
        cornerPageLabel.text = "Page \(String(1)) of \(String(1))"
        cornerPageLabel.numberOfLines = 1
        cornerPageLabel.textColor = UIColor.white
        cornerPageLabel.font = UIFont.systemFont(ofSize: 16.0)
        cornerPageLabel.backgroundColor = UIColor.lightGray
        cornerPageLabel.layer.cornerRadius = 5
        cornerPageLabel.layer.masksToBounds = true
        self.addSubview(cornerPageLabel)
        // Get margins for constrains
        let margins = superview?.layoutMarginsGuide
        // Set constraints for the page nuber notification
        cornerPageLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        cornerPageLabel.widthAnchor.constraint(equalToConstant: 105).isActive = true
        cornerPageLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerPageLabel.bottomAnchor.constraint(equalTo: (margins?.bottomAnchor)!, constant: -60).isActive = true
        cornerPageLabel.centerXAnchor.constraint(equalTo: (superview?.centerXAnchor)!).isActive = true
        
        pageNotificationFadeOut()
    }
    
    
    func updatePageNotification(onPage: Int, ofTotalPages: Int) {
        self.bringSubview(toFront: cornerPageLabel)
        cornerPageLabel.text = "Page \(String(onPage)) of \(String(ofTotalPages))"
        pageNotificationFadeIn()
        pageNotificationFadeOut()
    }
    
    func pageNotificationFadeOut() {
        UIView.animate(withDuration: 2.5, delay: 0.5, animations: {
            self.cornerPageLabel.alpha = 0.0
        })
    }
    
    func pageNotificationFadeIn() {
        UIView.animate(withDuration: 2.5) {
            self.cornerPageLabel.alpha = 1.0
        }
    }
       
    // MARK - JotViewDelegate functions
    // pragma mark - JotViewDelagate and other JotView stuff
    func changePenSize(to: CGFloat) {
        pen.maxSize = originalMaxSize * to
        pen.minSize = originalMinSize * to
    }
    
    func changePenColor(to: SelectedPenColor) {
        
        switch to {
            case .black:
                setPenColor(color: Constants.penColors.black)
            case .red:
                setPenColor(color: Constants.penColors.red)
            case .blue:
                setPenColor(color: Constants.penColors.blue)
            case .green:
                setPenColor(color: Constants.penColors.green)
        default:
            return
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
    
    func userSelected(writingInstrument: SelectedWritingInstrument){
        if(writingInstrument == .eraser){
            setPen(pen: .eraser)
        }
        if(writingInstrument == .pencil){
            setPen(pen: .pen)
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
        
        return CGFloat(0.4)
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
      //  didModifyDocument()
        let change = PaperChange.AddedStroke
        workViewPresenter?.strokeWasAdded(change)
       // FileSystemInteractor.archiveJotView(for: pages[currentPageIndex]!, project: project)
        
        //archiveJotView(page: currentPageIndex)
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
    
    
    // MARK: PageAndDrawingDelegate
    func clear() {
        let refreshAlert = UIAlertController(title: "Confirm Clear", message: "Are you sure you want to clear all of your writing? This cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //TODO: finish implementing the clear functionality
            self.workViewPresenter?.clear()
//            self.currentPage.clearDrawing()
//            self.archiveJotView(page: self.currentPageIndex)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
    }
   
    
    // MARK: Expression Delegate
    func didEvaluate(forExpression sender: Expression, result: Float){
        let currentPage: Paper = workViewPresenter!.currentPage
        let newBlock = BlockExpression.makeBlock(blockLocation: sender.center + CGPoint(x: sender.frame.width/2 + 80, y: 0)
            , blockType: TypeOfBlock.Number.rawValue, blockData: String(result))
        newBlock.removeFromSuperview()
        let express = BlockExpression(firstVal: newBlock)
        currentPage.addSubview(express)
        express.tag = -1
        currentPage.expressions.append(express as! BlockExpression)
        
        express.delegate = currentPage
        newBlock.frame.origin = CGPoint.zero
        express.addSubview(newBlock)

        let change = PaperChange.MovedBlock
        workViewPresenter!.blockWasMoved(change)
    }
    
    
    
    func didBeginMove(movedView: UIView) {
        customDelegate.unhideTrash()
    }
    
    func didIncrementMove(movedView: UIView){
        let currentPage: Paper = workViewPresenter!.currentPage
        var zoomedView = CGRect() //temp CGRect
        //if the block is from an InputObject
        if let movedBlock = movedView as? Block {
            zoomedView = movedBlock.frame
            
            zoomedView.origin = currentPage.convert(movedBlock.frame.origin, from: movedBlock.superview!)
        }
        //if a preexisting expression is being moved
        if let movedExpression = movedView as? Expression {
            zoomedView = movedExpression.frame
        }
        
        customDelegate.intersectsWithTrash(justMovedBlock: movedView)
        
        for group in currentPage.expressions {
            if let group = group as? BlockExpression {
                if(group != movedView){
                    if(group.isNear(incomingFrame: zoomedView)){
                        if(group.getIsDisplayingSpots() == false){
                            group.findAndShowAvailableSpots(_movedView: movedView)
                            //this will send the message to "group" that it needs to show its available spots for movedView
                        }
                        continue
                    }
                    group.hideSpots()
                }
            }
        }
    }
    
    func didCompleteMove(movedView: UIView){
        //checks if the block's been dropped above any of the dummy views
        //if the block is not above an existing BlockGroup's dummy view, then we create a new blockgroup including only the new block
        let currentPage: Paper = workViewPresenter!.currentPage
        var workingView = movedView
        customDelegate.hideTrash()
        
        /*check if expression overlaps with trash bin*/
        if(customDelegate.intersectsWithTrash(justMovedBlock: movedView)){
            currentPage.removeObject(object: movedView)
            
//            didModifyDocument()
//            archivePageObjects(page: currentPageIndex)
            return
        }
        
        if let block = movedView as? Block {
            let blockExpression = BlockExpression(firstVal: block)
            blockExpression.tag = -1
            
            blockExpression.frame.origin = currentPage.convert(movedView.frame.origin, from: movedView.superview!)
           
            currentPage.addSubview(blockExpression)
            blockExpression.addSubview(block)
            currentPage.expressions.append(blockExpression)
            blockExpression.delegate = currentPage
            block.frame.origin = CGPoint.zero
            block.parentExpression = blockExpression
            workingView = blockExpression
        }
        if let blockExpression = workingView as? BlockExpression {
            for group in currentPage.expressions {
                if let group = group as? BlockExpression {
                    if(group != blockExpression ){
                        for glow in group.getDummyViews(){
                            //see if any of the glow blocks contain the expression's origin
                            if(glow.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y).intersects(blockExpression.frame)){
                                //reset the position to be on the x,y coords of the "group"
                                blockExpression.frame = blockExpression.frame.offsetBy(dx: -group.frame.origin.x, dy: -group.frame.origin.y)
                                //removes from superview, we need to refrain from doing this because of the possibility that the _movedView becomes the superview
                                blockExpression.removeFromSuperview()
                                group.addSubview(blockExpression)
                                
                                //animate merging of groups and rearrange the ETree
                                //group.animateMove(movedView: expression, dummy: glow)
                                
                                blockExpression.frame = glow.frame
                                
                                group.frame = blockExpression.frame.offsetBy(dx: group.frame.origin.x, dy:group.frame.origin.y ) + group.frame
                                // ^ IS SAME AS BELOW ?
                                //group.frame = group.frame.union(expression.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y))
                                
                                //sets frame to include both rectangles
                                //maybe change this to a new function.. make new Expression frame
                                
                                //finally merge the expressions
                                let parent = glow.parent
                                if glow == parent?.leftChild{
                                    parent?.isAvailableOnLeft = false
                                    ETree.getRightestNode(root: blockExpression.rootBlock).isAvailableOnRight = false
                                    group.hideSpots()
                                    group.mergeExpressions(incomingExpression: blockExpression , side: "left")
                                    
                                    //set the position of, and reassign ownership of, the blocks that were added
                                    for sub in blockExpression.subviews {
                                        sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                        sub.removeFromSuperview()
                                        group.addSubview(sub)
                                    }
                                    
                                    //set the origins of the subviews to deal with the origin of the group having moved
                                    for sub in group.subviews {
                                        sub.frame = sub.frame.offsetBy(dx: glow.frame.width, dy: 0)
                                    }
                                }
                                if glow == parent?.rightChild{
                                    parent?.isAvailableOnRight = false
                                    ETree.getLeftestNode(root: blockExpression.rootBlock).isAvailableOnLeft = false
                                    group.hideSpots()
                                    group.mergeExpressions(incomingExpression: blockExpression , side: "right")
                                    for sub in blockExpression.subviews {
                                        sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                        sub.removeFromSuperview()
                                        group.addSubview(sub)
                                    }
                                }
                                if glow == parent?.innerChild{
                                    group.hideSpots()
                                    group.mergeExpressions(incomingExpression: blockExpression , side: "inner")
                                    for sub in blockExpression.subviews {
                                        sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                        sub.removeFromSuperview()
                                        group.addSubview(sub)
                                    }
                                }
                                //get rid of old expression, may need to make sure that there are no more references
                                currentPage.expressions.removeObject(object: blockExpression)
                                blockExpression.isHidden = true
                            }
                        }
                    }
                }
            }
        }
        hideAllSpots()
        let change = PaperChange.MovedBlock
        workViewPresenter?.blockWasMoved(change)
    }
    
    func hideAllSpots() {
        let currentPage: Paper = workViewPresenter!.currentPage
        for expression in currentPage.expressions {
            if let expression = expression as? BlockExpression {
            expression.hideSpots()
            }
        }
    }
    
    // MARK: trashbin
    func hideTrash(){
        customDelegate.hideTrash()
    }
    func unhideTrash(){
        customDelegate.unhideTrash()
    }
    
    func raiseAlert(title: String, alert: String){
        customDelegate.displayErrorInViewController(title: title, description: alert)
    }
    
    // MARK: init and helpers
    
    func setupForJotView() {
        self.setZoomScale(minimumZoomScale, animated: false)
        self.setZoomScale((maximumZoomScale + minimumZoomScale)/2, animated: false)
        self.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    
    
    func prepareForAnIncomingPage(){
        setZoomScale(minimumZoomScale, animated: false)
    }
    
    func setupJotPens() {
        pen = Pen(minSize: originalMinSize, andMaxSize: originalMaxSize, andMinAlpha: 1.0, andMaxAlpha: 1.0)
        pen.color = UIColor.black
        eraser = Eraser(minSize: 12.0, andMaxSize: 10.0, andMinAlpha: 0.6, andMaxAlpha: 0.8)
        pen.shouldUseVelocity = true
        // Setup pen
        curPen = .pen // Points to pen
    }
    
    func acceptAndConfigure(page: Paper){
        page.delegate = self
        self.addSubview(page)
        self.sendSubview(toBack: page)
        page.subviewDrawingView()
        page.contentMode = .scaleAspectFit
        page.isUserInteractionEnabled = true
        setupForJotView()
    }
    
    init(_ workViewPresenter: WorkViewPresenter){
        self.workViewPresenter = workViewPresenter
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        workViewPresenter.setWorkView(self)
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        setupJotPens()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
