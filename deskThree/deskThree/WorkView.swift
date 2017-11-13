//
//  workArea.swift
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
    func sendingToInputObject(for element: Any)
    func displayErrorInViewController(title: String, description: String)
}

class WorkView: UIScrollView, InputObjectDelegate, PaperDelegate, PageAndDrawingDelegate, JotViewDelegate {
    
    public weak var customDelegate: WorkViewDelegate!
    public private(set) var currentPage: Paper!
    
    private var pages: [Paper?] = [Paper]()
    private var currentPageIndex = 0
    private var totalPages = 0
    
    private var longPressGR: UILongPressGestureRecognizer!
    // stores metadata of this workspace. Initialized to untitled. can be
    // replaced with setDeskProject
    private var project: DeskProject!
    private var cornerPageLabel: UILabel!
    
    //states whether or not current page has been written to disk
    private var onDisk: Bool
    
    private var isInMetaData: Bool!
    
    private var pen: Pen!
    private var originalMinSize: CGFloat = 1.5
    private var originalMaxSize: CGFloat = 3.5
    private var eraser: Eraser!
    private var curPen = Constants.pens.pen
    private var selectedPaperType: SelectedPaperType = .graph
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupPageNumberSystem()
    }
    
    //MARK: Data Flow
    func passHeldBlock(sender: Expression) {
        customDelegate.sendingToInputObject(for: sender)
    }
    
    func receiveNewMathBlock(_ createdMathBlock: MathBlock){
        currentPage.addMathBlockToPage(block: createdMathBlock)
        didIncrementMove(movedView: createdMathBlock)
        didModifyDocument()
        archivePageObjects(page: currentPageIndex)
    }
    

    func getTotalNumberPages() -> Int {
        let totalPages = self.pages.count
        return totalPages
    }
    
    func getCurrentPageIndex() -> Int {
        return self.currentPageIndex + 1
    }
    
    func setupDelegateChain(){
        for page in pages {
            page?.delegate = self
            page?.setupDelegateChain()
        }
    }
    
    // Do not call this when superview is nill
    func setupPageNumberSystem(){
        if superview == nil {
            return
        }
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
        let margins = superview?.layoutMarginsGuide
        // Set constraints for the page nuber notification
        cornerPageLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        cornerPageLabel.widthAnchor.constraint(equalToConstant: 105).isActive = true
        cornerPageLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerPageLabel.bottomAnchor.constraint(equalTo: (margins?.bottomAnchor)!, constant: -60).isActive = true
        cornerPageLabel.centerXAnchor.constraint(equalTo: (superview?.centerXAnchor)!).isActive = true
        
        pageNotificationFadeOut()
    }
    
    
    func updatePageNotification() {
        self.bringSubview(toFront: cornerPageLabel)
        cornerPageLabel.text = "Page \(String(self.currentPageIndex+1)) of \(String(self.totalPages))"
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
    
//    func stylizeViews(){
//        for page in pages {
//            page?.stylizeViews()
//        }
//    }
    
    ///sets workarea's meta data object
    func setDeskProject(project: DeskProject){
        self.project = project
    }
    
    ///returns meta data for this workarea
    func getDeskProject() -> DeskProject {
        return project!
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
    
    
    func changePaper(to: SelectedPaperType){
        selectedPaperType = to
        for page in pages {
            page?.setBackground(to: selectedPaperType)
        }
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
        didModifyDocument()
        archiveJotView(page: currentPageIndex)
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
            self.currentPage.clearDrawing()
            self.archiveJotView(page: self.currentPageIndex)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
    }
    
    func undoTapped() {
        currentPage.drawingView.undo()
        archiveJotView(page: currentPageIndex)
    }
    
    func redoTapped() {
        currentPage.drawingView.redo()
        archiveJotView(page: currentPageIndex)
    }

    
    // MARK: Expression Delegate
    func didEvaluate(forExpression sender: Expression, result: Float){
        let newBlock = BlockExpression.makeBlock(blockLocation: sender.center + CGPoint(x: sender.frame.width/2 + 80, y: 0)
            , blockType: TypeOfBlock.Number.rawValue, blockData: String(result))
        newBlock.removeFromSuperview()
        let express = BlockExpression(firstVal: newBlock)
        currentPage.addSubview(express)
        express.tag = -1
        currentPage.expressions.append(express as! BlockExpression)
        express.delegate = self.currentPage
        newBlock.frame.origin = CGPoint.zero
        express.addSubview(newBlock)
        didModifyDocument()
        archivePageObjects(page: currentPageIndex)
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

    func addImageToPage(pickedImage: UIImage){
        currentPage.addImageBlock(pickedImage: pickedImage)
        didModifyDocument()
        archivePageObjects(page: currentPageIndex)
    }
    
    func didCompleteMove(movedView: UIView){
        //checks if the block's been dropped above any of the dummy views
        //if the block is not above an existing BlockGroup's dummy view, then we create a new blockgroup including only the new block
        var workingView = movedView
        customDelegate.hideTrash()
        
        /*check if expression overlaps with trash bin*/
        if(customDelegate.intersectsWithTrash(justMovedBlock: movedView)){
            currentPage.removeObject(object: movedView)
            
            didModifyDocument()
            archivePageObjects(page: currentPageIndex)
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
        didModifyDocument()
        archivePageObjects(page: currentPageIndex)
    }
    
    //gets called whenever the user modifies the document to save and save metadata
    func didModifyDocument(){
        if !isInMetaData {
            saveMetaData(name: project.name)
            isInMetaData = true
        }
        project.modify()
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
    
    func moveToNewPage(){
        // Tackles the edge case where first page is not saved
        if currentPageIndex == 0 {
            archivePageObjects(page: currentPageIndex)
            archiveJotView(page: currentPageIndex)
        }
        currentPageIndex += 1
        
        // Add a new page
        let paper = Paper()
        pages.append(paper)
        paper.setBackground(to: selectedPaperType)
        self.addSubview(pages[currentPageIndex]!)
        
        // Push back the old view
        self.sendSubview(toBack: pages[currentPageIndex - 1]!)
        pages[currentPageIndex - 1]?.isHidden = true
        
        // Bring forward the new view
        self.bringSubview(toFront: pages[currentPageIndex]!)
        pages[currentPageIndex]?.isHidden = false
        
        currentPage = pages[currentPageIndex]
        currentPage.delegate = self
        archivePageObjects(page: currentPageIndex)
        archiveJotView(page: currentPageIndex)
    }
    
    func moveRight(){
        currentPageIndex += 1
        
        loadPage(pageNo: currentPageIndex)
        
        // Move forward a page
        currentPage = pages[currentPageIndex]
        
        // Push back the old view
        self.sendSubview(toBack: pages[currentPageIndex - 1]!)
        pages[currentPageIndex - 1]?.isHidden = true
        
        // Bring forward the new view
        self.bringSubview(toFront: pages[currentPageIndex]!)
        pages[currentPageIndex]?.isHidden = false
    }
    
    func moveLeft(){
        currentPage.drawingView.removeFromSuperview()

        currentPageIndex -= 1
        loadPage(pageNo: currentPageIndex)
        
        // Push back the old view
        self.sendSubview(toBack: pages[currentPageIndex+1]!)
        pages[currentPageIndex+1]?.isHidden = true
        
        // Bring forward the new view
        self.bringSubview(toFront: pages[currentPageIndex]!)
        pages[currentPageIndex]?.isHidden = false
        
        currentPage = pages[currentPageIndex]
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
                moveToNewPage()
            } else {
                loadPage(pageNo: currentPageIndex)
                moveRight()

            }
        } else if direction == "left" {
            // Check if this is the first page
            if currentPageIndex != 0 {
                loadPage(pageNo: currentPageIndex)
                moveLeft()
            }
        }
        currentPage.drawingView.currentPage = currentPage
        // Insert the new drawing view onto DeskView
        currentPage.subviewDrawingView()
        initCurPage()
        updatePageNotification()
    }
    
    func raiseAlert(title: String, alert: String){
        customDelegate.displayErrorInViewController(title: title, description: alert)
    }
    
    // MARK: init and helpers
    // Do we even need to do this?
    func initCurPage() {
        currentPage.subviewDrawingView()
        //currentPage.boundInsideBy(superView: self, x1: 0, x2: 0, y1: 0, y2: 0)
        pages[currentPageIndex]?.contentMode = .scaleAspectFit
        currentPage.isUserInteractionEnabled = true
        currentPage.delegate = self
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
            let rect = page?.bounds
            UIGraphicsBeginPDFPageWithInfo(rect!, nil)
            guard let pdfContext = UIGraphicsGetCurrentContext() else { return false}
            
            var imageHolder: UIImage!
            page?.drawingView.exportToImage(onComplete:
                {(imageReady: UIImage?) in
                    imageHolder = imageReady!
                    // Signal that the onComplete block is done executing
                    imageReadySema.signal()
                }
                , withScale: 1.0)
            // Wait till the onComplete block is done
            imageReadySema.wait()
            page?.isHidden = false
            let useful: UIImageView = UIImageView (image: imageHolder)
            page?.addSubview(useful)
            page?.setNeedsDisplay()
            // Render the page contents into the PDF Context
            page?.layer.render(in: pdfContext)
            page?.isHidden = (page != self.currentPage) ? true : false
            useful.removeFromSuperview()
        }
        
        UIGraphicsEndPDFContext()
        
        return true
    }
    
    func getSerializedProjectName() -> String{
        let projects = PathLocator.loadMetaData()
    
        var names: [String] = []
        
        for project in projects {
            names.append(project.name)
        }

        var i = 1
        while names.contains("Untitled"+String(i)){
            i+=1
        }
        return "Untitled"+String(i)
    }
    
    func loadPage(pageNo: Int){
        
        let projectPath = PathLocator.getTempFolder() + "/" + project.name
        let pageAddr = projectPath+"/page" + String(pageNo+1) + "/page.desk"
        
        //page existed before, so get it from disk
        if(FileManager.default.fileExists(atPath: pageAddr) && pages[pageNo] == nil){
            let page = NSKeyedUnarchiver.unarchiveObject(withFile: pageAddr) as! Paper!
            pages[pageNo] = page!
            pages[pageNo]?.jotViewStateInkPath = PathLocator.getTempFolder()+"/"+project.name+"/page"+String(pageNo+1)+"/ink.png"
            pages[pageNo]?.jotViewStatePlistPath = PathLocator.getTempFolder()+"/"+project.name+"/page"+String(pageNo+1)+"/state.plist"
            pages[pageNo]?.setupDrawingView()
            pages[pageNo]?.stylizeViews()
            addSubview(pages[pageNo]!)
        }
    }
    
    // Cleans up the current project. Loads a new one and returns its name
    func newProject() -> String {
        setZoomScale(minimumZoomScale, animated: false)
        cleanUpPages()
        
        // Now initialize a new page
        let paper = Paper()
        paper.setBackground(to: selectedPaperType)
        paper.delegate = self
        pages.append(paper)
        self.addSubview(pages[0]!)
        currentPage = pages[0]
        initCurPage()
        self.sendSubview(toBack: pages[0]!)
        let name = getSerializedProjectName()
        self.project = DeskProject(name: name)
        self.onDisk = false
        self.isInMetaData = false
        return name
    }
    
    func loadProject(projectName: String){
        
        setZoomScale(minimumZoomScale, animated: false)
        cleanUpPages()
        
        let projectPath = PathLocator.getTempFolder()+"/"+projectName

        self.project.name = projectName
        
        var count = 1
        
        while(FileManager.default.fileExists(atPath: projectPath + "/page" + String(count))){
            pages.append(nil)
            count+=1
        }

        self.totalPages = count
        
        //after this is called, the first page should be in memory
        loadPage(pageNo: 0)
        self.currentPage = pages.first!
        
        // Do we even need this block anymore? All the other pages are nil anyway
        for view in self.subviews{
            if let paper = view as? Paper {
                paper.isHidden = true
            }
        }
        
        currentPage.isHidden = false

        initCurPage()
    }
    
    
    ///saves metadata of project to meta file. overwrite same name if present
    func saveMetaData(name: String){
        
        //creating metadata class instance and setting modified date to now
        self.project.modify()
        
        //saving updated meta data to disk
        let filePath = PathLocator.getMetaFolder()+"/Projects.meta"
        var projects = PathLocator.loadMetaData()
        for i in 0..<projects.count{
            if projects[i].name == name{
                //raise dialog asking user confirmation to overwrite
                projects[i] = project
                NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)
                return
            }
        }
        projects.append(project)
        NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)
    }
    
    func ensurePageDirExists() {
        let pageDir = PathLocator.getTempFolder()+"/"+project.name+"/page"+String(currentPageIndex+1)
        
        do {
            try FileManager.default.createDirectory(atPath: pageDir, withIntermediateDirectories: true, attributes: nil)
        }catch{
            print("dir for page already exists")
        }
    }
    
    func archivePageObjects(page: Int){
        ensurePageDirExists()
        if(!onDisk){
            onDisk = true
            archiveJotView(page: currentPageIndex)
        }
        let pageFolder = PathLocator.getTempFolder() + "/" + project.name + "/page"+String(page+1)
        NSKeyedArchiver.archiveRootObject(pages[page], toFile: pageFolder + "/page.desk")
    }
    
    // Used by saveAsView to save drawingStates
    func archiveJotView(page: Int){
        ensurePageDirExists()
        if(!onDisk){
            onDisk = true
            archivePageObjects(page: currentPageIndex)
        }
        let pageFolder = "/"+project.name+"/page"+String(page+1)
        pages[page]?.saveDrawing(at: pageFolder)
    }
    
    override func encode(with aCoder: NSCoder){
        super.encode(with: aCoder)
        aCoder.encode(pages)
    }
    
    func setupJotPens() {
        pen = Pen(minSize: originalMinSize, andMaxSize: originalMaxSize, andMinAlpha: 1.0, andMaxAlpha: 1.0)
        pen.color = UIColor.black
        eraser = Eraser(minSize: 12.0, andMaxSize: 10.0, andMinAlpha: 0.6, andMaxAlpha: 0.8)
        pen.shouldUseVelocity = true
        // Setup pen
        curPen = .pen // Points to pen
    }
    
    // Called before loading a new project
    private func cleanUpPages() {
        currentPage.drawingView.removeFromSuperview()
        for page in pages {
            page?.removePage()
        }
        pages.removeAll()
        currentPageIndex = 0
        print(pages.count)
    }
    
    // Called to free up memory on didRecieveMemoryWarning
    func freeInactivePages() {
        for i in 0..<pages.count {
            if(pages[i] != currentPage ){
                pages[i]?.removePage()
                pages.remove(at: i)
                pages.insert(nil, at: i)
            }
        }
    }
    
    init(){
        self.onDisk = false
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        let pape = Paper()
        pape.setBackground(to: selectedPaperType)
        pape.delegate = self
        pages.append(pape)
        self.addSubview(pages[0]!)
        currentPage = pages[0]
        print("\(CFGetRetainCount(currentPage as CFTypeRef))")
        initCurPage()
        print("\(CFGetRetainCount(currentPage as CFTypeRef))")
        self.sendSubview(toBack: pages[0]!)
        self.panGestureRecognizer.minimumNumberOfTouches = 2
        self.project = DeskProject(name: getSerializedProjectName())
//        setupPageNumberSystem()
        setupJotPens()
        isInMetaData = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}
