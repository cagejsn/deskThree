//
//  workArea.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit
import Mixpanel

protocol WorkViewDelegate {
    func intersectsWithTrash(justMovedBlock: UIView)->Bool
    func unhideTrash()
    func hideTrash()
    func sendingToInputObject(for element: Any)
    func displayErrorInViewController(title: String, description: String)
}

class WorkView: UIScrollView, InputObjectDelegate, PaperDelegate, PageAndDrawingDelegate {
    
    public var customDelegate: WorkViewDelegate!
    
    public var pages: [Paper] = [Paper]()
    public var currentPage: Paper!
    public var currentPageIndex = 0
    public var longPressGR: UILongPressGestureRecognizer!
    // stores metadata of this workspace. Initialized to untitled. can be
    // replaced with setDeskProject
    public var project: DeskProject!
    public var cornerPageLabel: UILabel!
    
    
    func enforceControlsState(pen: Constants.pens, color: UIColor){
        
        currentPage.setPenColor(color: color)
        currentPage.setPen(pen: pen)
        
    }

    func passHeldBlock(sender: Expression) {
        customDelegate.sendingToInputObject(for: sender)
    }
    
    func setupDelegateChain(){
        for page in pages {
            page.delegate = self
            page.setupDelegateChain()
        }
    }
    
    func setupPageNumberSystem(){
        cornerPageLabel = UILabel()
        cornerPageLabel.textAlignment = .center
        cornerPageLabel.text = "Page \(String(self.currentPageIndex+1)) of \(String(self.pages.count))"
        cornerPageLabel.numberOfLines = 1
        cornerPageLabel.textColor = UIColor.white
        cornerPageLabel.font = UIFont.systemFont(ofSize: 16.0)
        cornerPageLabel.backgroundColor = UIColor.lightGray
        cornerPageLabel.layer.cornerRadius = 5
        cornerPageLabel.layer.masksToBounds = true
        self.addSubview(cornerPageLabel)
        // Get margins for constrains
        let margins = self.layoutMarginsGuide
        // Set constraints for the page nuber notification
        cornerPageLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        cornerPageLabel.widthAnchor.constraint(equalToConstant: 105).isActive = true
        cornerPageLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerPageLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -60).isActive = true
        cornerPageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        pageNotificationFadeOut()
    }
    
    
    func updatePageNotification() {
        cornerPageLabel.text = "Page \(String(self.currentPageIndex+1)) of \(String(self.pages.count))"
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
    
    func stylizeViews(){
        for page in pages {
            page.stylizeViews()
        }
    }
    
    ///sets workarea's meta data object
    func setDeskProject(project: DeskProject){
        self.project = project
    }
    
    ///returns meta data for this workarea
    func getDeskProject() -> DeskProject {
        return project!
    }
    
    // MARK: PageAndDrawingDelegate
    func clearButtonTapped(_ sender: AnyObject) {
        // The backing texture does not get updated when we clear the JotViewGLContext. Hence,
        // We just load up a whole new state to get a cleared backing texture. I know, it is
        // hacky. I challenge you to find a cleaner way to do it in JotViewState's background Texture itself
        currentPage.reInitDrawingState()
        currentPage.drawingState.loadJotStateAsynchronously(false, with: currentPage.drawingView.bounds.size, andScale: currentPage.drawingView.scale, andContext: currentPage.drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        currentPage.drawingView.loadState(currentPage.drawingState)
        currentPage.drawingView.clear(true)
    }
    
    func undoTapped(_ sender: Any) {
        currentPage.drawingView.undo()
    }
    
    func redoTapped(_ sender: Any) {
        currentPage.drawingView.redo()
    }
    
    func getCurPen() -> Constants.pens {
        return currentPage.getCurPen()
    }
    
    func togglePen() {
        currentPage.togglePen()
    }
    
    func togglePenColor() {
        currentPage.togglePenColor()
    }
    
    func getCurPenColor() -> UIColor {
        return currentPage.getCurPenColor()
    }

    
    // MARK: Expression Delegate
    func didEvaluate(forExpression sender: Expression, result: Float){
        let newBlock = BlockExpression.makeBlock(blockLocation: CGPoint(x: sender.frame.origin.x + (sender.frame.width / 2) , y: sender.frame.origin.y + (3 * sender.frame.height)), blockType: TypeOfBlock.Number.rawValue, blockData: String(result))
        newBlock.removeFromSuperview()
        let express = BlockExpression(firstVal: newBlock)
        currentPage.addSubview(express)
        express.tag = -1
        currentPage.expressions.append(express as! BlockExpression)
        express.delegate = self.currentPage
        newBlock.frame.origin = CGPoint.zero
        express.addSubview(newBlock)
    }
    
    func elementWantsSendToInputObject(element:Any){
        customDelegate!.sendingToInputObject(for: element)
    }
    
    func didBeginMove(movedView: UIView) {
        customDelegate.unhideTrash()
    }
    
    func didIncrementMove(movedView: UIView){
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
        var workingView = movedView
        customDelegate.hideTrash()
        
        /*check if expression overlaps with trash bin*/
        if(customDelegate.intersectsWithTrash(justMovedBlock: movedView)){
            currentPage.expressions.removeObject(object: movedView)
            movedView.isHidden = true
            return
        }
        
        if let block = movedView as? Block {
            let blockExpression = BlockExpression(firstVal: block)
            blockExpression.tag = -1
            
            blockExpression.frame.origin = currentPage.convert(movedView.frame.origin, from: movedView.superview!)
           
            currentPage.addSubview(blockExpression)
            blockExpression.addSubview(block)
            currentPage.expressions.append(blockExpression)
            blockExpression.delegate = self.currentPage
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
        
    }
    
    func hideAllSpots() {
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
    
    
    /**
     Move to a page to the right
     If there is no page, add one and make it the current page
     */
    func movePage(direction: String) {
        // This line makes sure the jotView and workView zoomscales are in sync
        self.setZoomScale(minimumZoomScale, animated: false)
        
        if direction  == "right" {
            currentPage.drawingView.removeFromSuperview()
            // Check if this is the last page
            if currentPageIndex == pages.count - 1 {
                currentPageIndex += 1
                
                // Add a new page
                pages.append(Paper())
                self.addSubview(pages[currentPageIndex])
                
                // Push back the old view
                self.sendSubview(toBack: pages[currentPageIndex - 1])
                pages[currentPageIndex - 1].isHidden = true
                
                // Bring forward the new view
                self.bringSubview(toFront: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = false
                
                currentPage = pages[currentPageIndex]
                currentPage.delegate = self
            } else {
                currentPageIndex += 1
                
                // Move forward a page
                currentPage = pages[currentPageIndex]
                
                // Push back the old view
                self.sendSubview(toBack: pages[currentPageIndex - 1])
                pages[currentPageIndex - 1].isHidden = true
                
                // Bring forward the new view
                self.bringSubview(toFront: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = false
            }
            
            
        } else if direction == "left" {
            // Check if this is the first page
            if currentPageIndex != 0 {
                currentPage.drawingView.removeFromSuperview()
                // Push back the old view
                self.sendSubview(toBack: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = true
                
                currentPageIndex -= 1
                // Bring forward the new view
                self.bringSubview(toFront: pages[currentPageIndex])
                pages[currentPageIndex].isHidden = false
                
                currentPage = pages[currentPageIndex]
            }
        }
        currentPage.drawingView.currentPage = currentPage
        // Insert the new drawing view onto DeskView
        superview?.insertSubview(currentPage.drawingView, at: 1)
        initCurPage()
        updatePageNotification()
    }
    
    func raiseAlert(title: String, alert: String){
        customDelegate.displayErrorInViewController(title: title, description: alert)
    }
    
    // MARK: init and helpers
    // Do we even need to do this?
    func initCurPage() {
        currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[currentPageIndex].contentMode = .scaleAspectFit
        currentPage.isUserInteractionEnabled = true
//        self.delegate = currentPage
        setupForJotView()
    }
    
    func setupForJotView() {
        self.setZoomScale(minimumZoomScale, animated: false)
        self.setZoomScale((maximumZoomScale + minimumZoomScale)/2, animated: false)
        self.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    func exportPDF (to pdfData: NSMutableData) -> Bool {
        let imageReadySema = DispatchSemaphore(value: 0)
        
        UIGraphicsBeginPDFContextToData(pdfData, currentPage.bounds, nil)
        
        
        for page in pages {
            let rect = page.bounds
            UIGraphicsBeginPDFPageWithInfo(rect, nil)
            guard let pdfContext = UIGraphicsGetCurrentContext() else { return false}
            
            page.drawingView.exportToImage(onComplete: {[page] (imageV: UIImage?) in
                page.isHidden = false
                let useful: UIImageView = UIImageView (image: imageV)
                page.addSubview(useful)
                page.setNeedsDisplay()
                // Render the page contents into the PDF Context
                page.layer.render(in: pdfContext)
                page.isHidden = (page != self.currentPage) ? true : false
                useful.removeFromSuperview()
                // Signal that the onComplete block is done executing
                imageReadySema.signal()}
                , withScale: 1.66667)
            
            // Wait till the onComplete block is done
            imageReadySema.wait()
        }
        
        UIGraphicsEndPDFContext()
        
        return true
    }
    
    // Used by saveAsView to save drawingStates
    func archiveJotView(folderToZip: String){
        //        do{
        //            let files = try FileManager.default.contentsOfDirectory(atPath: folderToZip)
        //
        //            for file in files{
        //                try FileManager.default.removeItem(atPath: folderToZip+"/"+file)
        //            }
        //        }
        //        catch{
        //        }
        
        var count: Int = 1
        for page in pages {
            let pageFolder = folderToZip+"/page"+String(count)
            page.saveDrawing(at: pageFolder)
            count += 1
        }
        
    }
    
    override func encode(with aCoder: NSCoder){
        super.encode(with: aCoder)
        aCoder.encode(pages)
    }
    
    
    
    init(){
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        let pape = Paper()
        pape.delegate = self
        pages.append(pape)
        self.addSubview(pages[0])
        currentPage = pages[0]
        initCurPage()
        self.sendSubview(toBack: pages[0])
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        self.project = DeskProject(name: "Untitled")
        
        setupPageNumberSystem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Initialize the first page & set it as the current page
        let loadedPaper = aDecoder.decodeObject() as! [Paper]
        pages = loadedPaper
        self.currentPage = pages.first
        
        for view in self.subviews{
            view.isHidden = true
        }
        
        self.addSubview(currentPage)
        currentPage.isHidden = false
        initCurPage()
        self.panGestureRecognizer.minimumNumberOfTouches = 2

        setupPageNumberSystem()
    }
}
