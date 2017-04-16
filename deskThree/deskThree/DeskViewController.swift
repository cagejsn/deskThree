//
//  DeskViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import Mixpanel

// TODO: consider moving DeskControlModuleDelegate to WorkView
class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate, WorkViewDelegate, MAWMathViewDelegate, OCRMathViewDelegate, FileExplorerViewControllerDelegate, DeskControlModuleDelegate {

    let gkimagePicker = GKImagePicker()
    @IBOutlet var workView: WorkView!
    var deskControlModule: DeskControlModule!
    var lowerDeskControls: LowerDeskControls!
    

    var graphingBlock: GraphingBlock!
    var trashBin: Trash!
    var prevScaleFactor: CGFloat!
    var mathView: OCRMathView!
    
    var toolDrawer: ToolDrawer!
    
    var customContraints: [NSLayoutConstraint]!
    var myScriptConstraints: [NSLayoutConstraint]!
    
    var certificateRegistered: Bool!
    
    // Page number notifications
    var currentPage: Int!
    var totalPages: Int!
    
    // Mixpanel initialization
    var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")

    func didLoadState(_ state: JotViewStateProxy!) {
        
    }
    
    func didUnloadState(_ state: JotViewStateProxy!) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupWorkView()
        setupGKPicker()
        setupToolDrawer()
        setupTrash()
        setupDeskView()
        setupMyScript()
        setupDeskControlModule()
        setupLowerControls()
        // Setup file explorer buttons
    }
    
    

    
    func setupLowerControls(){
        lowerDeskControls = Bundle.main.loadNibNamed("LowerDeskControls", owner: nil, options: nil )?.first as!LowerDeskControls!
       // lowerDeskControls.frame = CGRect(x: 10, y: UIScreen.main.bounds.height - 54, width: 216, height: 44)
        self.view.addSubview(lowerDeskControls)
        lowerDeskControls.translatesAutoresizingMaskIntoConstraints = false

        let margins = view.layoutMarginsGuide
        lowerDeskControls.heightAnchor.constraint(equalToConstant: 44).isActive = true
        lowerDeskControls.widthAnchor.constraint(equalToConstant: 216).isActive = true
        lowerDeskControls.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0).isActive = true
        lowerDeskControls.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -10).isActive = true
        
        lowerDeskControls.delegate = workView
        lowerDeskControls.layoutSubviews()
    }
    
    func setupDeskControlModule(){
        deskControlModule = DeskControlModule(frame: CGRect(x: 10, y: 20, width: 44, height: 44), moduleDelegate: self, pageDelegate: workView)
        self.view.addSubview(deskControlModule)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(_: animated)
        workView.setupForJotView()
    }
    

    func saveButtonTapped(_ sender: Any) {
        let view = Bundle.main.loadNibNamed("SaveAsView", owner: self, options: nil)?.first as? SaveAsView
        self.view.addSubview(view!)
        if(workView != nil){
        view?.workViewRef = workView
        }
        view?.center = self.view.center
        view?.layer.shadowOffset = CGSize(width: -3, height: 3)
        view?.layer.shadowRadius = 3
        view?.layer.shadowOpacity = 0.5
        view?.layer.cornerRadius = 5
    }
    
    
    func fileExplorerButtonTapped(_ sender: Any) {
        let fileExplorer = FileExplorerViewController()
        fileExplorer.delegate = self
        self.present(fileExplorer, animated: false, completion: nil)
    }
    
    func dismissFileExplorer(){
        self.dismiss(animated: false, completion: nil)
    }
    
    func didSelectProject(projectPath: String){
        // Mixpanel event
        mixpanel.track(event: "Project Selected")

        //gets rid of old workView
        eliminateOldWorkView(workViewToElimate: self.workView)
        setupWorkView()
        
        workView.loadProject(projectPath: projectPath)
        
        dismissFileExplorer()
        
        setupDeskView()
        setupDelegateChain()
        workView.stylizeViews()
    }
    
    // TODO: Not updating the delagates to new workView did not cause an exception.
    // This means that there may be an extra workView floating around when we load a new one.
    func setupDelegateChain(){
        lowerDeskControls.delegate = workView
        deskControlModule.pageAndDrawingDelegate = workView
        workView.setupDelegateChain()
    }
    
    func toggleEraser(_ sender: Any) {
    }
    
    // MARK - UIScrollViewDelegate functions
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if(prevScaleFactor != nil){
            workView.currentPage.drawingView.transform = workView.currentPage.drawingView.transform.scaledBy(x: scrollView.zoomScale/prevScaleFactor, y: scrollView.zoomScale/prevScaleFactor)
        }
        workView.currentPage.drawingView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
        prevScaleFactor = scrollView.zoomScale        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Mixpanel event
        mixpanel.track(event: "Gesture: Scroll")

        workView.currentPage.drawingView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
    }
    
    //incoming view does intersect with Trash?
    func intersectsWithTrash(justMovedBlock: UIView) -> Bool {
        if( trashBin.frame.contains(self.view.convert(justMovedBlock.frame.origin + CGPoint(x: 0, y:justMovedBlock.frame.height), from: justMovedBlock.superview!))){
            trashBin.open()
            return true
        }
        trashBin.close()
        return false
    }
    
    ///expression delegate for trash disappear
    func hideTrash(){
        // Mixpanel event
        mixpanel.track(event: "Trash Hidden")
        trashBin.hide()
    }
    
    ///expression delegate for trash appear
    func unhideTrash(){
        // Mixpanel event
        mixpanel.track(event: "Trash Unhidden")
        trashBin.unhide()
    }
    
    //MARK: Setup Functions called from viewDidLoad
    func setupTrash(){
        trashBin = Trash()
        self.view.addSubview(trashBin)
        trashBin.setupTrash()
        trashBin.hide()
    }
    
    func setupWorkView(workSpace: WorkView = WorkView()){
        workView = workSpace
        if(toolDrawer != nil){
            toolDrawer.delegate = workView
        }
        workView.delegate = self
        workView.customDelegate = self
        self.view.sendSubview(toBack: workView)
        workView.minimumZoomScale = 0.6
        workView.maximumZoomScale = 2.0
        self.view.insertSubview(workView, at: 0)
        workView.boundInsideBy(superView: self.view, x1: 0, x2: 0, y1: 0, y2: 0)
        workView.currentPage.subviewDrawingView()
    }
    
    //TODO: This should soon go
    func eliminateOldWorkView(workViewToElimate: WorkView){
        if (workViewToElimate == self.workView){
            workViewToElimate.setZoomScale(workViewToElimate.minimumZoomScale, animated: false)
            workViewToElimate.currentPage.drawingView.removeFromSuperview()
            workViewToElimate.removeFromSuperview()
            workView = nil
        }
    }
    
    func setupGKPicker(){
        gkimagePicker.delegate = self
        gkimagePicker.cropSize = CGSize(width: 320, height: 320)
        gkimagePicker.resizeableCropArea = true
    }
    
    func setupToolDrawer(){
        toolDrawer = ToolDrawer()
        self.view.addSubview(toolDrawer)
        toolDrawer.setupConstraints()
        toolDrawer.delegate = workView
    }
    
    func setupDeskView(){
        if let dView = view as? DeskView {
            dView.setup()
            dView.addGestureRecognizer(workView.panGestureRecognizer)
            dView.addGestureRecognizer(workView.pinchGestureRecognizer!)
        }
    }
    
    // TODO: Should we subclass MAWMathView and push all of this code in there?
    func setupMyScript(){
        let certificate: Data = NSData(bytes: myCertificate.bytes, length: myCertificate.length) as Data
        mathView = OCRMathView(frame: CGRect(x: 100, y: UIScreen.main.bounds.height - 500 , width: UIScreen.main.bounds.width - 200, height: 400))
        
        certificateRegistered = mathView.registerCertificate(certificate)
        
        if(certificateRegistered!){
            mathView.delegate = self
            
            let mainBundle = Bundle.main
            var bundlePath = mainBundle.path(forResource: "resources", ofType: "bundle") as! NSString
            bundlePath = bundlePath.appendingPathComponent("conf") as NSString
            mathView.addSearchDir(bundlePath as String)
            mathView.configure(withBundle: "math", andConfig: "standard")
            mathView.paddingRatio = UIEdgeInsetsMake(7, 7, 7, 7)
            
        }
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(DeskViewController.createMathBlock))
        doubleTapGR.numberOfTapsRequired = 2
        mathView.layer.cornerRadius = 10
        mathView.clipsToBounds = true
        mathView.layer.borderColor = UIColor.gray.cgColor
        mathView.layer.borderWidth = 2
        mathView.beautificationOption = MAWBeautifyOption.fontify
        
        mathView.delegate2 = self   
    }
    
    func sendingToInputObject(for element: Any){
        if let mathElement = element as? MathBlock {
            mathView.clear(true)
            mathView.addSymbols(mathElement.mathSymbols, allowUndo: true)
        }
        toolDrawer.passElement(element)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    
    
    //MARK: - WorkView Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workView.currentPage
    }

    
    //MARK: UIToolbar on click methods
    func printButtonPushed(_ sender: Any) {
        let pdfFileName = PDFGenerator.createPdfFromView(workView: workView, saveToDocumentsWithFileName: "Preview")
        let pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
        pdfShareHelper.delegate = self
        pdfShareHelper.uti = "com.adobe.pdf"
        // Currently, Preview itself gives option to share
        pdfShareHelper.presentPreview(animated: false)
    }
    
    
    /**
     Load Image
     ----------
     Allows user to bring an image into the work area
     */
    func loadImageButtonPushed(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            let alert = UIAlertController(title: "Choose a Photo", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
//            alert.popoverPresentationController?.sourceView = self.view
//            alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 200, height: 200)
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
                action in
                self.gkimagePicker.imagePickerController.sourceType = .camera
                self.present(self.gkimagePicker.imagePickerController, animated: false, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
                action in self.gkimagePicker.imagePickerController.sourceType = .photoLibrary
                self.present(self.gkimagePicker.imagePickerController, animated: false, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        } else {
            self.present(gkimagePicker.imagePickerController, animated: false, completion: nil)
        }
    }
    
    ///this function will present a MAWMathView to the User
    func mathFormulaButtonTapped(_ sender: Any) {
        if(mathView.superview == nil){
            mixpanel.track(event: "Button: MyScript Box: Export")
            self.view.addSubview(mathView)
            setupMathViewConstraints()
        } else {
            mixpanel.track(event: "Button: MyScript Box: Clear")
            mathView.clear(true)
            mathView.removeFromSuperview()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func setupMathViewConstraints(){
        mathView.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: mathView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 100)
        let rightConstraint = NSLayoutConstraint(item: mathView, attribute: .trailing, relatedBy: .equal, toItem: toolDrawer, attribute: .leading, multiplier: 1.0, constant: -100)
        let bottomConstraint = NSLayoutConstraint(item: mathView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -75)
        let heightConstraint = NSLayoutConstraint(item: mathView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300)
        
        myScriptConstraints = [leftConstraint,rightConstraint,bottomConstraint,heightConstraint]
        self.view.addConstraints(myScriptConstraints)
        
    }
    
    func mathViewDidBeginConfiguration(_ mathView: MAWMathView!) {
        
    }
    
    func mathView(_ mathView: MAWMathView!, didFailConfigurationWithError error: Error!) {
        NSLog("unable to config", error.localizedDescription)
        print(error.localizedDescription)
    }
    
    func mathViewDidBeginRecognition(_ mathView: MAWMathView!) {
        
    }
    
    func mathViewDidEndRecognition(_ mathView: MAWMathView!) {

    }
    
    func createMathBlock(){
        
        if let image1 =  mathView.resultAsImage(){
            let mathBlock = MathBlock(image: image1, symbols: mathView.resultAsSymbolList(), text: mathView.resultAsText())
            mathBlock.delegate = workView.currentPage
            workView.currentPage.addMathBlockToPage(block: mathBlock)
            var loc = self.view.center
            loc = loc - CGPoint(x: 0, y: 200)
            mathBlock.center = mathBlock.convert(loc, to: workView.currentPage)
            self.workView.currentPage.addSubview(mathBlock)
        }
       
    }
    
    func printText(){
        print(mathView.resultAsLaTeX())
    }

    
    
    // MARK: GKImagePickerController Delegate
    @objc func imagePicker(_ imagePicker: GKImagePicker,  pickedImage: UIImage) {
        // Mixpanel event
        mixpanel.track(event: "User At Image Picker Screen")
        
        workView.currentPage.addImageBlock(pickedImage: pickedImage)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func feedbackButtonTapped(_ sender: Any) {
        let svc = SFSafariViewController(url: NSURL(string: "https://docs.google.com/forms/d/e/1FAIpQLScW_-4-4PmJdlqe0aV45IIZTJqL8fvW90f60-H7BI82sdja6A/viewform?usp=sf_link") as! URL)
        self.present(svc, animated: true, completion: nil)
        
    }
    
    func didRequestWRDisplay(query: String){
        let newQuery = query.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        
        let svc = SFSafariViewController(url: NSURL(string: "https://www.wolframalpha.com/input/?i=" + newQuery) as! URL)
        self.present(svc, animated: true, completion: nil)
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
