//
//  DeskViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit


// TODO: consider moving DeskControlModuleDelegate to WorkView
class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate, WorkViewDelegate, MAWMathViewDelegate, OCRMathViewDelegate, FileExplorerViewControllerDelegate, DeskControlModuleDelegate {

    
    let gkimagePicker = GKImagePicker()
    @IBOutlet var workView: WorkView!
    var deskControlModule: DeskControlModule!
    var lowerDeskControls: LowerDeskControls!
    

//    var graphingBlock: GraphingBlock!
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
    var cornerPageLabel: UILabel!
        
    func didLoadState(_ state: JotViewStateProxy!) {
        
    }
    
    func didUnloadState(_ state: JotViewStateProxy!) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupWorkView()
        setupGKPicker()
        setupJotView()
        setupToolDrawer()
        setupTrash()
        setupDeskView()
        setupMyScript()
        setupPageNumberSystem()
        setupDeskControlModule()
        setupLowerControls()
        // Setup file explorer buttons
    }
    
    func setupPageNumberSystem(){
        // Setup page number notification
        self.currentPage = 1
        self.totalPages = 1
        cornerPageLabel = UILabel()
        cornerPageLabel.textAlignment = .center
        cornerPageLabel.text = "Page \(String(self.currentPage)) of \(String(self.totalPages))"
        cornerPageLabel.numberOfLines = 1
        cornerPageLabel.textColor = UIColor.white
        cornerPageLabel.font = UIFont.systemFont(ofSize: 16.0)
        cornerPageLabel.backgroundColor = UIColor.lightGray
        cornerPageLabel.layer.cornerRadius = 5
        cornerPageLabel.layer.masksToBounds = true
        self.view.addSubview(cornerPageLabel)
        // Get margins for constrains
        let margins = view.layoutMarginsGuide
        // Set constraints for the page nuber notification
        cornerPageLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        cornerPageLabel.widthAnchor.constraint(equalToConstant: 105).isActive = true
        cornerPageLabel.translatesAutoresizingMaskIntoConstraints = false
        cornerPageLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -60).isActive = true
        cornerPageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
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
        
        lowerDeskControls.delegate = self
        lowerDeskControls.layoutSubviews()
    }
    
    func undoTapped(_ sender: Any) {
        workView.currentPage.drawingView.undo()
    }
    
    func redoTapped(_ sender: Any) {
        workView.currentPage.drawingView.redo()
    }
    
    func getCurPen() -> Constants.pens {
        return workView.currentPage.getCurPen()
    }
    
    func togglePen() {
        workView.currentPage.togglePen()
    }
    
    func togglePenColor() {
        workView.currentPage.togglePenColor()
    }
    
    func getCurPenColor() -> UIColor {
        return workView.currentPage.getCurPenColor()
    }

    
    func archiveJotView(folderToZip: String){
        
        var archivedPages = 0
        
        func doNothing(ink: UIImage? , thumb: UIImage?, state : JotViewImmutableState?) -> Void{
            archivedPages+=1
        }
        
        archivedPages = 0
        var inkLocation: String
        var stateLocation: String
        var thumbLocation: String
        let temp = PathLocator.getTempFolder()
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
        for page in workView.pages {
            let pageFolder = folderToZip+"/page"+String(count)
            do {
                print(temp+pageFolder)
                try FileManager.default.createDirectory(atPath: temp+pageFolder, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
            
            inkLocation = pageFolder+"/ink"+".png"
            stateLocation = pageFolder+"/state"+".plist"
            thumbLocation = pageFolder+"/thumb"+".png"
            
            
            page.drawingState.isForgetful = false
            page.drawingView.exportImage(to: temp+inkLocation, andThumbnailTo: temp+thumbLocation, andStateTo: temp+stateLocation, andJotState: page.drawingState, withThumbnailScale: 1.0, onComplete: doNothing)
            page.jotViewStateInkPath = inkLocation
            page.jotViewStatePlistPath = stateLocation
            count += 1
        }

    }

    
    func setupDeskControlModule(){
        deskControlModule = DeskControlModule(frame: CGRect(x: 10, y: 20, width: 44, height: 44))
        deskControlModule.deskViewControllerDelegate = self
        self.view.addSubview(deskControlModule)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(_: animated)
        workView.setupForJotView()
        pageNotificationFadeOut()
    }
    
    func updatePageNotification() {
        cornerPageLabel.text = "Page \(String(self.currentPage)) of \(String(self.totalPages))"
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
    
    func didSelectProject(newWorkView:WorkView){
        //gets rid of old workView
        eliminateOldWorkView(workViewToElimate: self.workView)
        
        
        setupWorkView(workSpace: newWorkView)
        
        dismissFileExplorer()
      
        setupJotView()
        setupDeskView()
        workView.setupDelegateChain()
        workView.stylizeViews()
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

    }
    
    func eliminateOldWorkView(workViewToElimate: WorkView){
        
        if (workViewToElimate == self.workView){
            workViewToElimate.setZoomScale(workViewToElimate.minimumZoomScale, animated: false)
            workViewToElimate.removeFromSuperview()
            workView = nil
            if let dView = self.view as? DeskView {
                if (dView.jotView == workViewToElimate.currentPage.drawingView){
                    dView.jotView.removeFromSuperview()
                    dView.jotView = nil
                }
            }
        }
    }
    
    func setupGKPicker(){
        gkimagePicker.delegate = self
        gkimagePicker.cropSize = CGSize(width: 320, height: 320)
        gkimagePicker.resizeableCropArea = true
    }
    

    

    
    func setupJotView(){
        // inserting jotView right below toolbar. This is the only line that needs to be here
        // Call this wherever we call setupJotView
        self.view.insertSubview(workView.currentPage.drawingView, at: 1)
    }
    
    func setupToolDrawer(){
        toolDrawer = ToolDrawer()
        self.view.addSubview(toolDrawer)
        toolDrawer.setupConstraints()
        toolDrawer.delegate = workView
    }
    
    func setupDeskView(){
        if let dView = view as? DeskView {
            dView.workView = workView
            dView.jotView = workView.currentPage.drawingView
            dView.setup()
            dView.addGestureRecognizer(workView.panGestureRecognizer)
            dView.addGestureRecognizer(workView.pinchGestureRecognizer!)
        }
    }
    
    // TODO: Should we subclass MAWMathView and push all of this code in there?
    func setupMyScript(){
        
        var certificate: Data = NSData(bytes: myCertificate.bytes, length: myCertificate.length) as Data
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
     Pagination
     ----------
     Allows user to move forwards and backwards in pages
     */
 
    func lastPageTapped(_ sender: Any) {
        // This line makes sure the jotView and workView zoomscales are in sync
        workView.setZoomScale(workView.minimumZoomScale, animated: false)
        
        
        let pagesInfo = workView.movePage(direction: "left")
        self.currentPage = pagesInfo.currentPage + 1
        self.totalPages = pagesInfo.totalNumPages
        
        workView.currentPage.drawingView.currentPage = workView.currentPage
        
        setupJotView()
        workView.initCurPage()
        updatePageNotification()
    }
    
    
    
    func nextPageTapped(_ sender: Any) {
        // This line makes sure the jotView and workView zoomscales are in sync
        workView.setZoomScale(workView.minimumZoomScale, animated: false)

        let pagesInfo = workView.movePage(direction: "right")
        
        self.currentPage = pagesInfo.currentPage + 1
        self.totalPages = pagesInfo.totalNumPages
        
        // TODO: this line needs to go if its not used anymore
        workView.currentPage.drawingView.currentPage = workView.currentPage
        
        setupJotView()
        workView.initCurPage()
        updatePageNotification()
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
            self.view.addSubview(mathView)
            setupMathViewConstraints()
        } else {
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

    
    func clearButtonTapped(_ sender: AnyObject) {
        // The backing texture does not get updated when we clear the JotViewGLContext. Hence,
        // We just load up a whole new state to get a cleared backing texture. I know, it is 
        // hacky. I challenge you to find a cleaner way to do it in JotViewState's background Texture itself
        workView.currentPage.reInitDrawingState()
        workView.currentPage.drawingState.loadJotStateAsynchronously(false, with: workView.currentPage.drawingView.bounds.size, andScale: workView.currentPage.drawingView.scale, andContext: workView.currentPage.drawingView.context, andBufferManager: JotBufferManager.sharedInstance())
        workView.currentPage.drawingView.loadState(workView.currentPage.drawingState)
        workView.currentPage.drawingView.clear(true)
        
    }
    // MARK: GKImagePickerController Delegate
    @objc func imagePicker(_ imagePicker: GKImagePicker,  pickedImage: UIImage) {
        if let pickedImage = pickedImage as? UIImage  {
            let imageBlock: ImageBlock = ImageBlock(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            workView.currentPage.images?.append(imageBlock) //adds to the array, used to toggle editable
            workView.currentPage.addSubview(imageBlock)
            imageBlock.center = self.view.center
            imageBlock.isUserInteractionEnabled = true
            imageBlock.contentMode = .scaleAspectFit
            imageBlock.setImage(image: pickedImage)
            imageBlock.delegate = self.workView.currentPage
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                workView.currentPage.addSubview(image)
                workView.currentPage.images?.append(image) //adds to the array, used to toggle editable
                image.center = self.view.center
                image.isUserInteractionEnabled = true
                image.contentMode = .scaleAspectFit
                image.delegate = self.workView.currentPage
                
            }
            //workView.currentPage.loadPaper(state: savedFile)
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
