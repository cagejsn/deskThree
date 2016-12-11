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
    
    //var workArea: WorkArea!
    
    @IBOutlet var workArea: WorkArea!
   
    //calculator properties
    var allPad: InputObject?
    var isPadActive: Bool = false
    var expressions: [Expression] = []

    //JotUI Properties
    var pen: Pen!
    var jotView: JotView!
    var paperState: JotViewStateProxy!
    var jotViewStateInkPath: String!
    var jotViewStatePlistPath: String!

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
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
 
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    //MARK: - WorkArea Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workArea.currentPage
    }
    
    @IBAction func setImagesButtonPushed(_ sender: AnyObject) {
        for i in 0 ..< workArea.currentPage.images!.count {
            workArea.currentPage.images![i].toggleEditable()
        }
    }
    
    @IBAction func rightSideScreenEdgePanGestureRecognizer(_ sender: AnyObject) {
        allPad = AllPad()
        self.view.addSubview(allPad!)
        allPad?.delegate = self
    }
    
    //need to work on this
    func hello(imageV: UIImage?){
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

        jotView.exportToImage(onComplete: hello , withScale: (workArea.currentPage.image?.scale)!)

        //workArea.frame = workArea.currentPage.frame
//        var pdfFileName = PDFGenerator.createPdfFromView(aView: workArea.currentPage, saveToDocumentsWithFileName: "secondPDF")
//        var pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
//        pdfShareHelper.delegate = self
//        pdfShareHelper.uti = "com.adobe.pdf"
//        // Currently, Preview itself gives option to share
//        pdfShareHelper.presentPreview(animated: false)
        //pdfShareHelper.presentOptionsMenu(from: self.workArea.frame, in: self.workArea, animated: false)
        //workArea.boundInsideBy(superView: self.view, x1: 0, x2: 0, y1: 0, y2: 44)
    }

    @IBAction func undoButtonPressed(_ sender: AnyObject) {
    jotView.undo()
    }
    
    @IBAction func loadImageButtonPushed(_ sender: UIBarButtonItem) {
    present(gkimagePicker.imagePickerController, animated: true, completion: nil)
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
            imageBlock.editAndSetImage(image: pickedImage)
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
        for group in expressions {
            if(group != _movedView){
                /*
 expression.frame.origin.x = (expression.frame.origin.x + workArea.contentOffset.x) / workArea.zoomScale
 expression.frame.origin.y = (expression.frame.origin.y + workArea.contentOffset.y) / workArea.zoomScale
 */
                
                if(group.isNear(incomingFrame: _movedView.frame)){
                    if(group.isDisplayingSpots == false){
                        group.findAndShowAvailableSpots(_movedView: _movedView)
                        //this will send the message to "group" that it needs to show its available spots for movedView
                    }
                    continue
                }
                group.hideSpots()
            }
        }
    }
    
    func didCompleteMove(_movedView: UIView) {
        //checks if the block's been dropped above any of the dummy views
        //if the block is not above an existing BlockGroup's dummy view, then we create a new blockgroup including only the new block
        var workingView = _movedView
        
        if let block = _movedView as? Block {
            var expression = Expression(firstVal: block)
            //self.view.addSubview(expression)
            expression.tag = -1

          //  expression.frame.origin.x = (expression.frame.origin.x + workArea.contentOffset.x) / workArea.zoomScale
         //   expression.frame.origin.y = (expression.frame.origin.y + workArea.contentOffset.y) / workArea.zoomScale
            workArea.currentPage.addSubview(expression)
            //block.removeFromSuperview()
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
                        if(glow.frame.offsetBy(dx: group.frame.origin.x, dy: group.frame.origin.y).contains(expression.frame.origin)){
                            
                            // all of this is to move the actual block
                            
                            //reset the position to be on the x,y coords of the "group"
                            expression.frame = expression.frame.offsetBy(dx: -group.frame.origin.x, dy: -group.frame.origin.y)
                            
                            //removes from superview, we need to refrain from doing this because of the possibility that the _movedView becomes the superview
                            expression.removeFromSuperview()
                            group.addSubview(expression)
                            
                            
                            //animate merging of groups and rearrange the ETree
                            //group.animateMove(movedView: expression, dummy: glow)
                            
                            
                            //here take over and fix things
                            
                            
                            //this sets the frame of the expression equal to the glow
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
    }
    

    //MARK: Expression Delegate
    
    func didEvaluate(result: Float) {
        var funct = InputObject.makeBlockForOutputArea(allPad!)
        var newBlock = funct(CGPoint(x: 1250 / 2, y: 1650 / 2), TypeOfBlock.Number.rawValue, String(result))
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


extension CGRect {
    static func +(left: CGRect , right: CGRect) -> CGRect{
        var returnRect: CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: left.width + right.width, height: left.height))
        
        if(left.origin.x < right.origin.x){
            returnRect.origin = left.origin
        } else {
            returnRect.origin = right.origin
        }
        return returnRect
    }
}
