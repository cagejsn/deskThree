//
//  DeskViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//
import UIKit

class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate, JotViewDelegate, JotViewStateProxyDelegate, InputObjectDelegate, ExpressionDelegate {
    
    let gkimagePicker = GKImagePicker()
    @IBOutlet var workArea: WorkArea!
   
    //calculator properties
    var allPad: InputObject?
    var isPadActive: Bool = false
    
    //should be a part of workArea.currentPage
    var expressions: [Expression] = []

    //JotUI Properties
    var pen: Pen!
    var jotView: JotView!
    var paperState: JotViewStateProxy!
    var jotViewStateInkPath: String!
    var jotViewStatePlistPath: String!
    var graphingBlock: GraphingBlock!
    var trashBin: Trash!
    var toolDrawer: ToolDrawer!
    
    var customContraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        workArea.delegate = self
        self.view.sendSubview(toBack: workArea)
        workArea.minimumZoomScale = 0.6
        workArea.maximumZoomScale = 2.0
        //workArea is loaded from Nib
        
        gkimagePicker.delegate = self
        gkimagePicker.cropSize = CGSize(width: 320, height: 320)
        gkimagePicker.resizeableCropArea = true
        
        
        //JotUI setup
        pen = Pen()
        jotView = JotView(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))
        jotView.delegate = self
        jotView.isUserInteractionEnabled = true
        paperState = JotViewStateProxy(delegate: self)
        paperState?.delegate = self
        paperState?.loadJotStateAsynchronously(false, with: jotView.bounds.size, andScale: UIScreen.main.scale, andContext: jotView.context, andBufferManager: JotBufferManager.sharedInstance())
        jotView.loadState(paperState)
        workArea.currentPage.addSubview(jotView)

 
        
       
     //   graphView = GraphView(frame: CGRect(x:100,y:100,width:100,height:100), context: EAGLContext(api: EAGLRenderingAPI.openGLES2))
     //   self.view.addSubview(graphView)
      //  graphingBlock = GraphingBlock(frame: CGRect(x:100,y:100,width:200,height:200))
        
        
        setupToolDrawer()
        

        
        // Calculator setup
        allPad = AllPad()
        allPad?.delegate = self
        
        //ititialize trash receiver
        trashBin = Trash()
        self.view.addSubview(trashBin)
        trashBin.setupTrash()
        trashBin.hide()
    }
    
    func setupToolDrawer(){
        toolDrawer = ToolDrawer()
        self.view.addSubview(toolDrawer)
        toolDrawer.setupConstraints()
        toolDrawer.delegate = self
        
        
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
 
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    ///expression delegate for trash disappear
    func hideTrash(){
        trashBin.hide()
    }
    
    ///expression delegate for trash appear
    func unhideTrash(){
        trashBin.unhide()
    }
    
    //MARK: - WorkArea Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workArea.currentPage
    }
    
    
    // Opens the calculator
    @IBAction func rightSideScreenEdgePanGestureRecognizer(_ sender: UIGestureRecognizer) {
        if(!(allPad?.isDescendant(of: self.view))!){
            // TODO: add sliding animation to make it more appealing
            self.view.addSubview(allPad!)
        
            print(toolDrawer.frame)
        }
    }
    
    func exportPdf(imageV: UIImage?){
//        self.view = UIImageView (image: imageV)
//        var pngRep: Data = UIImagePNGRepresentation (imageV!)!;
        
        var useful: UIImageView = UIImageView (image: imageV)
        workArea.currentPage.addSubview(useful)
        var pdfFileName = PDFGenerator.createPdfFromView(aView: workArea.currentPage, saveToDocumentsWithFileName: "secondPDF")
        var pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
        pdfShareHelper.delegate = self
        pdfShareHelper.uti = "com.adobe.pdf"
        // Currently, Preview itself gives option to share
        pdfShareHelper.presentPreview(animated: false)
        useful.removeFromSuperview()
    }
    
    //MARK: UIToolbar on click methods
    @IBAction func printButtonPushed(_ sender: UIBarButtonItem) {

         workArea.frame = workArea.currentPage.frame
        jotView.exportToImage(onComplete: exportPdf , withScale: (workArea.currentPage.image?.scale)!)

       
//        var pdfFileName = PDFGenerator.createPdfFromView(aView: workArea.currentPage, saveToDocumentsWithFileName: "secondPDF")
//        var pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
//        pdfShareHelper.delegate = self
//        pdfShareHelper.uti = "com.adobe.pdf"
//        // Currently, Preview itself gives option to share
//        pdfShareHelper.presentPreview(animated: false)
//        pdfShareHelper.presentOptionsMenu(from: self.workArea.frame, in: self.workArea, animated: false)
        workArea.boundInsideBy(superView: self.view, x1: 0, x2: 0, y1: 0, y2: 44)
    }

    @IBAction func undoButtonPressed(_ sender: AnyObject) {
    jotView.undo()
    }
    
    @IBAction func loadImageButtonPushed(_ sender: UIBarButtonItem) {
    present(gkimagePicker.imagePickerController, animated: true, completion: nil)
    }
    @IBAction func graphButtonPushed(_ sender: Any) {
        var function = Bundle.loadNibNamed(Bundle.main)
        var graphingBlock = function("GraphingBlock", self, nil)?.first as? UIView
        self.view.addSubview(graphingBlock!)
        graphingBlock?.center = self.view.center
        
     //   self.workArea.addSubview(graph)
        
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
    jotView.clear(true);
    }
// MARK: GKImagePickerController Delegate
@objc func imagePicker(_ imagePicker: GKImagePicker,  pickedImage: UIImage) {
        if let pickedImage = pickedImage as? UIImage  {
            var imageBlock: ImageBlock = ImageBlock(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            workArea.currentPage.images?.append(imageBlock) //adds to the array, used to toggle editable
            workArea.currentPage.addSubview(imageBlock)
            imageBlock.center = self.view.center
            imageBlock.isUserInteractionEnabled = true
            imageBlock.contentMode = .scaleAspectFit
            imageBlock.setImage(image: pickedImage)
            imageBlock.delegate = self.workArea.currentPage
        }
        dismiss(animated: true, completion: nil)        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //pragma mark - Helpers
    func activePen() -> Pen {
        return pen
    }

    //JotUIDelegate
    func textureForStroke() -> JotBrushTexture! {
        return activePen().textureForStroke()
    }
    
    func stepWidthForStroke() -> CGFloat {
        return activePen().stepWidthForStroke()
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
        var userDocumentsPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return userDocumentsPaths.first!
    }
    
    func didLoadState(_ state: JotViewStateProxy!) {

    }
    
    func didUnloadState(_ state: JotViewStateProxy!) {
        
    }
    
    //MARK: - InputObject Delegate
    
    //this gets called when moving a blockGroup and when a block from the inputObject is being dragged around
    func didIncrementMove(_movedView: UIView) {
        var zoomedView = CGRect() //temp CGRect
        //if the block is from an InputObject
        if let movedBlock = _movedView as? Block {
            zoomedView = movedBlock.frame
            zoomedView.origin = CGPoint(x: (workArea.contentOffset.x + movedBlock.frame.origin.x ) / workArea.zoomScale, y: (workArea.contentOffset.y + movedBlock.frame.origin.y) / workArea.zoomScale)
        }
        //if a preexisting expression is being moved
        if let movedExpression = _movedView as? Expression {
            zoomedView = movedExpression.frame
        }
        for group in expressions {
            if(group != _movedView){
                if(group.isNear(incomingFrame: zoomedView)){
                    if(group.isDisplayingSpots == false){
                        group.findAndShowAvailableSpots(_movedView: _movedView)
                        //this will send the message to "group" that it needs to show its available spots for movedView
                    }
                    continue
                }
                group.hideSpots()
            }
        }
        if(intersectsWithTrash(justPlacedBlock: _movedView)){
            trashBin.open()
        }
        else{
            trashBin.closed()
        }
    }
    
    func didCompleteMove(_movedView: UIView) {
        //checks if the block's been dropped above any of the dummy views
        //if the block is not above an existing BlockGroup's dummy view, then we create a new blockgroup including only the new block
        var workingView = _movedView
        
        /*check if expression overlaps with trash bin*/
        if(intersectsWithTrash(justPlacedBlock: _movedView)){
            print("deleting expression")
            expressions.removeObject(object: _movedView)
            _movedView.isHidden = true
            return
        }
        
        if let block = _movedView as? Block {
            var expression = Expression(firstVal: block)
            expression.tag = -1
            //could make this line better with operator overloading for CGPoint
            expression.frame.origin = CGPoint(x: (workArea.contentOffset.x + _movedView.frame.origin.x ) / workArea.zoomScale, y: (workArea.contentOffset.y + _movedView.frame.origin.y) / workArea.zoomScale)
            workArea.currentPage.addSubview(expression)
            expression.addSubview(block)
            self.expressions.append(expression)
            expression.delegate = self
            block.frame.origin = CGPoint.zero
            block.parentExpression = expression
            workingView = expression
        }
        if var expression = workingView as? Expression {
            
            

            
            
            for group in expressions {
                if(group != expression ){
                    for glow in group.dummyViews{
                        //see if any of the glow blocks contain the expression's origin
                        if(glow.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y).intersects(expression.frame)){
                            //reset the position to be on the x,y coords of the "group"
                            expression.frame = expression.frame.offsetBy(dx: -group.frame.origin.x, dy: -group.frame.origin.y)
                            //removes from superview, we need to refrain from doing this because of the possibility that the _movedView becomes the superview
                            expression.removeFromSuperview()
                            group.addSubview(expression)
                            
                            //animate merging of groups and rearrange the ETree
                            //group.animateMove(movedView: expression, dummy: glow)

                            expression.frame = glow.frame
                        
                            group.frame = expression.frame.offsetBy(dx: group.frame.origin.x, dy:group.frame.origin.y ) + group.frame
                            // ^ IS SAME AS BELOW ?
                            //group.frame = group.frame.union(expression.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y))
                            
                            //sets frame to include both rectangles
                            //maybe change this to a new function.. make new Expression frame
                        
                            //finally merge the expressions
                            let parent = glow.parent
                            if glow == parent?.leftChild{
                                parent?.isAvailableOnLeft = false
                                ETree.getRightestNode(root: expression.rootBlock).isAvailableOnRight = false
                                group.hideSpots()
                                group.mergeExpressions(incomingExpression: expression , side: "left")
                                
                                //set the position of, and reassign ownership of, the blocks that were added
                                for sub in expression.subviews {
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
                                ETree.getLeftestNode(root: expression.rootBlock).isAvailableOnLeft = false
                                group.hideSpots()
                                group.mergeExpressions(incomingExpression: expression , side: "right")
                                for sub in expression.subviews {
                                    sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                    sub.removeFromSuperview()
                                    group.addSubview(sub)
                                }
                            }
                            if glow == parent?.innerChild{
                                group.hideSpots()
                                group.mergeExpressions(incomingExpression: expression , side: "inner")
                                for sub in expression.subviews {
                                    sub.frame = sub.frame.offsetBy(dx: glow.frame.origin.x , dy: glow.frame.origin.y)
                                    sub.removeFromSuperview()
                                    group.addSubview(sub)
                                }
                            }
                            //get rid of old expression, may need to make sure that there are no more references
                            expressions.removeObject(object: expression)
                            expression.isHidden = true
                        } 
                    }
                }
            }
        }
        hideAllSpots()  
    }
    
    func intersectsWithTrash(justPlacedBlock: UIView) -> Bool {
        
        let x = (justPlacedBlock.frame.origin.x*workArea.zoomScale - workArea.contentOffset.x)
        let y = ((justPlacedBlock.frame.origin.y*workArea.zoomScale - workArea.contentOffset.y))
        if(x < trashBin.frame.width && y > trashBin.frame.origin.y){
            return true
            
        }
        return false
    }
    
    func hideAllSpots() {
        for expression in expressions {
            expression.hideSpots()
        }
    }

    //MARK: Expression Delegate    
    func didEvaluate(forExpression sender: Expression, result: Float) {
        var funct = InputObject.makeBlockForOutputArea(allPad!)
        var newBlock = funct(CGPoint(x: sender.frame.origin.x + (sender.frame.width / 2) , y: sender.frame.origin.y + (3 * sender.frame.height)), TypeOfBlock.Number.rawValue, String(result))
        newBlock.removeFromSuperview()
        var express = Expression(firstVal: newBlock)
        workArea.currentPage.addSubview(express)
        express.tag = -1
        expressions.append(express)
        express.delegate = self
        newBlock.frame.origin = CGPoint.zero
        express.addSubview(newBlock)
        
        
        //self.view.addSubview(newBlock)
        // newBlock.userInteractionEnabled = true
    }

}


