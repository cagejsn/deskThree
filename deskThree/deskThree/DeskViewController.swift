//
//  DeskViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit


class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate, JotViewDelegate, JotViewStateProxyDelegate, WorkAreaDelegate {
    
    let gkimagePicker = GKImagePicker()
    @IBOutlet var workArea: WorkArea!
    
    //JotUI Properties
    var pen: Pen!
    var jotView: JotView!
    var paperState: JotViewStateProxy!
    var jotViewStateInkPath: String!
    var jotViewStatePlistPath: String!
    var graphingBlock: GraphingBlock!
    var trashBin: Trash!
    var prevScaleFactor: CGFloat!
    
    var toolDrawer: ToolDrawer!
    
    var customContraints: [NSLayoutConstraint]!
    
    @IBOutlet weak var currentPageLabel: UILabel!
    @IBOutlet weak var totalPagesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupWorkArea()
        setupGKPicker()
        setupJotView()
        setupToolDrawer()
        setupTrash()
        
        currentPageLabel.text = "1"
        totalPagesLabel.text = "1"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(_: animated)
        workArea.setZoomScale(workArea.minimumZoomScale, animated: false)
    }
    
    // MARK - UIScrollViewDelegate functions
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if(prevScaleFactor != nil){
            
            jotView.transform = jotView.transform.scaledBy(x: scrollView.zoomScale/prevScaleFactor, y: scrollView.zoomScale/prevScaleFactor)
            
        }
        print(scrollView.zoomScale)
        print(scrollView.contentScaleFactor)
        jotView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)

        prevScaleFactor = scrollView.zoomScale
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        
        jotView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
    }
    
    
    //incoming view does intersect with Trash?
    func intersectsWithTrash(justMovedBlock: UIView) -> Bool {
        if( trashBin.frame.contains(self.view.convert(justMovedBlock.frame.origin, from: justMovedBlock.superview!))){
            trashBin.open()
            return true
        }
        trashBin.close()
        return false
    }
    
    ///expression delegate for trash disappear
    func hideTrash(){
        trashBin.hide()
    }
    
    ///expression delegate for trash appear
    func unhideTrash(){
        trashBin.unhide()
    }
    
    //MARK: Setup Functions called from viewDidLoad
    func setupTrash(){
        trashBin = Trash()
        self.view.addSubview(trashBin)
        trashBin.setupTrash()
        trashBin.hide()
    }
    
    func setupWorkArea(){
        workArea.delegate = self
        workArea.customDelegate = self
        self.view.sendSubview(toBack: workArea)
        workArea.minimumZoomScale = 0.6
        workArea.maximumZoomScale = 2.0
    }
    
    func setupGKPicker(){
        gkimagePicker.delegate = self
        gkimagePicker.cropSize = CGSize(width: 320, height: 320)
        gkimagePicker.resizeableCropArea = true
    }
    
    func setupJotView(){
        pen = Pen()
        jotView = JotView(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))
        jotView.delegate = self
        jotView.isUserInteractionEnabled = true
        paperState = JotViewStateProxy(delegate: self)
        paperState?.delegate = self
        paperState?.loadJotStateAsynchronously(false, with: jotView.bounds.size, andScale: UIScreen.main.scale, andContext: jotView.context, andBufferManager: JotBufferManager.sharedInstance())
        jotView.loadState(paperState)
        // inserting jotView right below toolbar
        self.view.insertSubview(jotView, at: 1)
        jotView.isUserInteractionEnabled = false
    }
    
    func setupToolDrawer(){
        toolDrawer = ToolDrawer()
        self.view.addSubview(toolDrawer)
        toolDrawer.setupConstraints()
        toolDrawer.delegate = workArea
    }
    
    func sendingToInputObject(for element: Any){
        toolDrawer.passElement(element)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    
    
    //MARK: - WorkArea Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workArea.currentPage
    }
    
    
    
    func exportPdf(imageV: UIImage?){
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
        workArea.boundInsideBy(superView: self.view, x1: 0, x2: 0, y1: 0, y2: 44)
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        print("UNDO!")
        jotView.undo()
    }
    
    /**
     Pagination
     ----------
     Allows user to move forwards and backwards in pages
     */
    
    @IBAction func pageRightButtonPressed(_ sender: Any) {
        print("Right!")
        let pagesInfo = workArea.movePage(direction: "right")
        currentPageLabel.text = String(pagesInfo.currentPage + 1)
        totalPagesLabel.text = String(pagesInfo.totalNumPages)
    }
    
    @IBAction func pageLeftButtonPressed(_ sender: Any) {
        print("Left!")
        let pagesInfo = workArea.movePage(direction: "left")
        currentPageLabel.text = String(pagesInfo.currentPage + 1)
        totalPagesLabel.text = String(pagesInfo.totalNumPages)
    }
    
    
    /**
     Load Image
     ----------
     Allows user to bring an image into the work area
     */
    @IBAction func loadImageButtonPushed(_ sender: UIBarButtonItem) {
        if( UIImagePickerController.isSourceTypeAvailable(.camera)){
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
                action in
                self.gkimagePicker.imagePickerController.sourceType = .camera
                self.present(self.gkimagePicker.imagePickerController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
                action in
                self.gkimagePicker.imagePickerController.sourceType = .photoLibrary
                self.present(self.gkimagePicker.imagePickerController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.present(gkimagePicker.imagePickerController, animated: false, completion: nil)
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        jotView.clear(true)
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
    
    @IBAction func didPressSave(_ sender: Any) {
        print("should save")
        workArea.pages[0].savePaper()
    }
    
    ///unpacks and loads in whatever is at /file.desk
    @IBAction func didPressLoad(_ sender: Any) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! String
        var filePath = documentsPath.appending("/file.desk")
        print(filePath)
        let file = NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
        if let savedFile = file as? Paper{
            print(savedFile)
            for image in savedFile.images! {
                
                print(image.frame.origin.x)
                print(image.imageHolder.image)
                
                //reminder, add wrapper for image initialization.
                workArea.currentPage.addSubview(image)
                workArea.currentPage.images?.append(image) //adds to the array, used to toggle editable
                image.center = self.view.center
                image.isUserInteractionEnabled = true
                image.contentMode = .scaleAspectFit
                image.delegate = self.workArea.currentPage
                
            }
            //workArea.currentPage.loadPaper(state: savedFile)
            //savedFile.delegate = self
            //self.present(viewController, animated: false, completion: nil)
        }
    }
    
    public func displayErrorInViewController(title: String, description : String){
        let alertController = UIAlertController(title: title, message:
            description, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
