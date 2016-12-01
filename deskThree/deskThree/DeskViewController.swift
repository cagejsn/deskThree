//
//  DeskViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//
import UIKit

class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate, JotViewDelegate, JotViewStateProxyDelegate {
    
    var jotViewStateInkPath: String!
    var jotViewStatePlistPath: String!
    
   
   // let imagePicker = UIImagePickerController()
    let gkimagePicker = GKImagePicker()
    @IBOutlet var workArea: WorkArea!
    var singleTouchPanGestureRecognizer: UIPanGestureRecognizer!
    
    var pen: Pen!
    
    var jotView: JotView!
    var paperState: JotViewStateProxy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        workArea.delegate = self
        self.view.sendSubview(toBack: workArea)
        workArea.minimumZoomScale = 0.3
        workArea.maximumZoomScale = 2.0
        
        gkimagePicker.delegate = self
        gkimagePicker.cropSize = CGSize(width: 320, height: 320)
        gkimagePicker.resizeableCropArea = true
       
        pen = Pen()
        
      
        jotView = JotView(frame: CGRect(x: 0, y: 0, width: 1236, height: 1600))
        //var jotView = JotView(frame: self.view.frame)

        jotView.delegate = self
        
        workArea.currentPage.addSubview(jotView)
        //self.view.addSubview(jotView)
        
        jotView.isUserInteractionEnabled = true 
        
        paperState = JotViewStateProxy(delegate: self)
        paperState?.delegate = self
        
        paperState?.loadJotStateAsynchronously(false, with: jotView.bounds.size, andScale: UIScreen.main.scale, andContext: jotView.context, andBufferManager: JotBufferManager.sharedInstance())
        
        jotView.loadState(paperState)
        

    /*
        
        JotViewStateProxy* paperState = [[JotViewStateProxy alloc] initWithDelegate:self];
        paperState.delegate = self;
        
        
        [paperState loadJotStateAsynchronously:NO withSize:jotView.bounds.size andScale:[[UIScreen mainScreen] scale] andContext:jotView.context andBufferManager:[JotBufferManager sharedInstance]];
        [jotView loadState:paperState];
        
        [self changePenType:nil];
        
        [self tappedColorButton:blackButton];
        
        marker.color = [redButton backgroundColor];
        pen.color = [blackButton backgroundColor];
        
        
        */
        
        
        
        
        
        
        
        
       // var metalDevice = MTLCreateSystemDefaultDevice()
      //  let metalCommandQueue = metalDevice?.makeCommandQueue()
        
     //   var activeDrawing: ActiveDrawing = ActiveDrawing(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 44), device: metalDevice)
        
     //   activeDrawing.commandQueue = metalCommandQueue
        //activeDrawing.loadUIImage(image: UIImage(named: "wave")!)
        
     //   var storedDrawing: StoredDrawing = StoredDrawing(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 44), device: metalDevice, activeResource: activeDrawing)
    //    storedDrawing.commandQueue = metalCommandQueue
    //    storedDrawing.loadUIImage(image: UIImage(named: "apple")!)
     //   self.view.addSubview(storedDrawing)
   //     self.view.addSubview(activeDrawing)

        
        
        
        /*
        workArea = WorkArea()
        self.view.addSubview(workArea)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
        
        workArea.minimumZoomScale = 0.1
        workArea.maximumZoomScale = 2.0
        */
        // setting up the GR that will handle drawing w finger & stylus
        singleTouchPanGestureRecognizer = UIPanGestureRecognizer(target: workArea.currentPage, action: #selector(Paper.handlePan))
        singleTouchPanGestureRecognizer.minimumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.maximumNumberOfTouches = 1
        //singleTouchPanGestureRecognizer.isEnabled = true
        singleTouchPanGestureRecognizer.isEnabled = false
        singleTouchPanGestureRecognizer.delegate = self
        //self.view.addGestureRecognizer(singleTouchPanGestureRecognizer)
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
 
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    //function to handle the drawing (is in paper.swift)
    func handleSinglePan(sender: UIPanGestureRecognizer) {
        // workArea.currentPage.handlePan(sender: sender)
        // self.view.backgroundColor = UIColor.green
      //  self.workArea.isHidden = true
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
    
    
    
    
    //MARK: UIToolbar on click methods
    @IBAction func printButtonPushed(_ sender: UIBarButtonItem) {

        
        //jotView.exportToImage(onComplete: (workArea.currentPage.image) , withScale: workArea.currentPage.image?.scale)
        //workArea.frame = workArea.currentPage.frame
        var pdfFileName = PDFGenerator.createPdfFromView(aView: workArea.currentPage, saveToDocumentsWithFileName: "secondPDF")
        var pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
        pdfShareHelper.delegate = self
        pdfShareHelper.uti = "com.adobe.pdf"
        // Currently, Preview itself gives option to share
        pdfShareHelper.presentPreview(animated: false)
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
    
    /*
    - (UIColor*)colorForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    [[self activePen] setShouldUseVelocity:pressureVsVelocityControl.selectedSegmentIndex];
    return [[self activePen] colorForCoalescedTouch:coalescedTouch fromTouch:touch];
    }
    */
    
    func width(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        //activePen().shouldUseVelocity
        return activePen().width(forCoalescedTouch: coalescedTouch, from: touch)
    }
    
    /*
    - (CGFloat)widthForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    [[self activePen] setShouldUseVelocity:pressureVsVelocityControl.selectedSegmentIndex];
    return [[self activePen] widthForCoalescedTouch:coalescedTouch fromTouch:touch];
    }
    */
    
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
    
    
    
    /*
    @property(nonatomic, readonly) NSString* jotViewStateInkPath;
    
    @property(nonatomic, readonly) NSString* jotViewStatePlistPath;
    
    - (void)didLoadState:(JotViewStateProxy*)state;
    
    - (void)didUnloadState:(JotViewStateProxy*)state;
 
    */
    
    
    
    
    
    
    
    
    
/*
    
    
    - (NSString*)jotViewStateInkPath {
    return [[self documentsDir] stringByAppendingPathComponent:@"ink.png"];
    }
    
    - (NSString*)jotViewStateThumbPath {
    return [[self documentsDir] stringByAppendingPathComponent:@"thumb.png"];
    }
    
    - (NSString*)jotViewStatePlistPath {
    return [[self documentsDir] stringByAppendingPathComponent:@"state.plist"];
    }
    
    - (void)didLoadState:(JotViewStateProxy*)state {
    }
    
    - (void)didUnloadState:(JotViewStateProxy*)state {
    }

    */
    
    
    
    
}

