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
import SlideMenuControllerSwift



// TODO: consider moving DeskControlModuleDelegate to WorkView
class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate, WorkViewDelegate, MAWMathViewDelegate, FileExplorerViewControllerDelegate, UITextFieldDelegate, HamburgerMenuViewControllerDelegate, MathViewContainerDelegate, StrokeToMathToggleControlDelegate {

    let gkimagePicker = GKImagePicker()
    @IBOutlet var workView: WorkView!

    //MARK: TOOLBAR PROPERTIES
    @IBOutlet var projectNameTextField: UITextField!
    @IBOutlet var pageRightButton: UIBarButtonItem!
    @IBOutlet var pageLeftButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!
    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var hamburgerMenuButton: UIBarButtonItem!
    @IBOutlet var pageNumberLabel: UIBarButtonItem!
    
    var pencilEraserToggleControl: PencilEraserToggleControl!
    var strokeToMathToggleControl: StrokeToMathToggleControl!
    
    private var trashBin: Trash!
    private var prevScaleFactor: CGFloat!
    
    //Other Views with important Functionality
    private var mathViewContainer: MathViewContainer!
    private var toolDrawer: ToolDrawer!
    private var penControls: UIView! //to be used later
    private var customContraints: [NSLayoutConstraint]!
    private var myScriptConstraints: [NSLayoutConstraint]!
    private var workViewPresenter: WorkViewPresenter!
    
    //MARK: Lifecycle functions for DVC
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupWorkView()
        setupGKPicker()
        setupToolDrawer()
        setupDeskView()
        setupToolbar()
        setupMathViewContainer()
        setupTrash()
        setupPencilEraserToggleControl()
        setupStrokeToMathToggleControl()
        setupPageNumberLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(_: animated)
        workView.setupForJotView()
    }
    
    func setupPageNumberLabel() {
        self.pageNumberLabel.title = "1 of 1"
    }
    
    //MARK: Setup functions for the various components
    func setupWorkView(){
        workViewPresenter = WorkViewPresenter(self)
        workViewPresenter.updateDVCPageLabelHandler = self.recievePageNumberLabelUpdate(onPage:ofTotalPages:)
        workView = WorkView(workViewPresenter)
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
        workViewPresenter.loadNewProject()
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
    
    func setupToolbar(){
        projectNameTextField.delegate = self
        projectNameTextField.text = workViewPresenter.currentProject.getName()
    }
    
    func setupMathViewContainer(){
        mathViewContainer = MathViewContainer(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 44, width: UIScreen.main.bounds.width - 44, height: 44))
        self.view.addSubview(mathViewContainer)
        mathViewContainer.delegate = self
        mathViewContainer.setupConstraints()
    }
    
    func setupTrash(){
        trashBin = Trash()
        self.view.addSubview(trashBin)
        trashBin.setupTrash(lowerView: mathViewContainer)
        trashBin.hide()
    }
    
    func getItemForMathViewRightConstraint() -> UIView {
        return self.toolDrawer
    }

    func setupPencilEraserToggleControl(){
        pencilEraserToggleControl = PencilEraserToggleControl(frame: CGRect(x: 20, y: 70, width: 140, height: 40))
        self.view.addSubview(pencilEraserToggleControl)
        pencilEraserToggleControl.delegate = workViewPresenter
    }
    
    func setupStrokeToMathToggleControl(){
        strokeToMathToggleControl = StrokeToMathToggleControl(type: .custom)
        strokeToMathToggleControl.frame = CGRect(x: 170, y: 70, width: 70, height: 40)
        self.view.addSubview(strokeToMathToggleControl)
        strokeToMathToggleControl.delegate = self
        strokeToMathToggleControl.addTarget(workViewPresenter, action: #selector(WorkViewPresenter.toggleClipping(_:)), for: .touchUpInside)
        strokeToMathToggleControl.setImage(#imageLiteral(resourceName: "magicWand"), for: .normal)
        strokeToMathToggleControl.imageView?.contentMode = .scaleAspectFit
        strokeToMathToggleControl.isSelected = false
        strokeToMathToggleControl.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        strokeToMathToggleControl.layer.cornerRadius = 7
        strokeToMathToggleControl.layer.borderWidth = 3
        strokeToMathToggleControl.layer.borderColor = UIColor.init(colorLiteralRed: 0, green: 191/255, blue: 1.0, alpha: 1.0).cgColor
        strokeToMathToggleControl.adjustsImageWhenHighlighted = false
        
    }
    
    //MARK: Data flow functions
    func sendingToInputObject(for element: Any, toDestination: ExpressionDestination){
        guard let mathBlock = element as? MathBlock else { return }
        switch toDestination {
            case .MathView:
                mathViewContainer.receiveElement(mathBlock)
            case .Calculator:                
                toolDrawer.receiveElement(mathBlock)
            case .Wolfram:
                didRequestWRDisplay(query: mathBlock.getMathML())
            default:
                break
        }
    }
    
    //MARK: UITextfieldDelegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //validate the text of textField
        if(textField.text == "" || (textField.text?.contains(" "))! ){
            return false
        }
        return true
    }
    
    // MARK - UIScrollViewDelegate functions
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if(prevScaleFactor != nil){
            workViewPresenter.currentPage.drawingView.transform = workViewPresenter.currentPage.drawingView.transform.scaledBy(x: scrollView.zoomScale/prevScaleFactor, y: scrollView.zoomScale/prevScaleFactor)
        }
        workViewPresenter.currentPage.drawingView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
        prevScaleFactor = scrollView.zoomScale        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        workViewPresenter.currentPage.drawingView.frame.origin = CGPoint(x:-scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
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
    
    // MARK: UITOOLBAR ACTIONS
    @IBAction func hamburgerMenuButtonTapped(_ sender: Any) {
        self.slideMenuController()?.openLeft()
    }
    
    @IBAction func redoTapped(){
        workViewPresenter.redo()
    }
    
    @IBAction func undoTapped(){
        workViewPresenter.undo()
    }
    
    var tempStorageForOldProjectNameTextField: String?
    
    /// called when the project name textField returns
    @IBAction func editingDidBeginInProjectNameField(_ sender: Any) {
        tempStorageForOldProjectNameTextField = projectNameTextField.text!
    }
    @IBAction func projectNameChanged(_ sender: Any) {
        if(tempStorageForOldProjectNameTextField == projectNameTextField.text!){return}
        if(!workViewPresenter.renameProject(projectNameTextField.text!)){
            projectNameTextField.text = tempStorageForOldProjectNameTextField
            AnalyticsManager.track(.RenameProjectDVC)
            tempStorageForOldProjectNameTextField = nil
        }
    }
    
    func getOpenProjectSerialNumber() -> Int {
        return workViewPresenter.currentProject.getUniqueProjectSerialNumber()
    }
    
    func getChangeOpenProjectNameHandler() -> (String) -> (Bool) {
        return { newName in self.projectNameTextField.text = newName ; return self.changeNameOfOpenDeskProject(to: newName)}
    }
    
    func changeNameOfOpenDeskProject(to newName: String) -> Bool{
//        workViewPresenter.currentProject.rename(name: newName)
        return workViewPresenter.renameProject(newName)
    }
    
    
    
    //a delegate function from FileExplorer
    func setProjectTitleIfOpenProjectRenamed(_ oldProjectName: String, _ newProjectName: String, _ grouping: Grouping){
        let openProject = workViewPresenter.currentProject
        let openProjectName = openProject!.getName()
        let openGrouping = workViewPresenter.currentGrouping
        let openGroupingName = openGrouping.getName()
        
        if(oldProjectName == openProjectName && grouping.getName() == openGroupingName){
            openProject!.rename(name: newProjectName)
            projectNameTextField.text = newProjectName
        }
        
    }
        
    @IBAction func lastPageTapped(){
        workViewPresenter.movePage(direction: "left")
    }
    
    @IBAction func nextPageTapped(){
        workViewPresenter.movePage(direction: "right")
    }
    
    func recievePageNumberLabelUpdate(onPage: Int , ofTotalPages: Int) {
        self.pageNumberLabel.title = "\(String(onPage)) of \(String(ofTotalPages))"
    }
    
    //MARK: - WorkView Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workViewPresenter.currentPage
    }
    
    //MARK: FileExplorerViewControllerDelegate
    func dismissFileExplorer(){
        self.dismiss(animated: false, completion: nil)
    }
    
    func didSelectProject(grouping: Grouping, project: DeskProject){
        
        dismissFileExplorer()
        workViewPresenter.openProject(project: project, grouping: grouping)
        projectNameTextField.text = project.getName()
        
        
        
        
    }

    //MARK: HamburgerMenuViewControllerDelegate functions
    func newProjectRequested() {
        workViewPresenter.newProjectRequested(in: nil)
        setupPageNumberLabel()
        projectNameTextField.text = workViewPresenter.currentProject.getName()

    }
    
    //MARK: Method used when new Project is tapped in the File Explorer
    func newProjectRequestedIn(_ grouping: Grouping){
        
        workViewPresenter.newProjectRequested(in: grouping)
        setupPageNumberLabel()
        projectNameTextField.text = workViewPresenter.currentProject.getName()
        dismissFileExplorer()
        
    }
    
    func openProjectWasRenamed(to newName: String){
        projectNameTextField.text = newName
    }
    
    func fileExplorerButtonTapped() {
        let fileExplorer = FileExplorerViewController()
        fileExplorer.delegate = self
        self.present(fileExplorer, animated: false, completion: nil)
    }

    func printButtonPushed() {
        let pdfFileName = PDFGenerator.createPdfFromView(workViewPresenter: workViewPresenter, saveToDocumentsWithFileName: "Preview")
        let pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
        pdfShareHelper.delegate = self
        pdfShareHelper.uti = "com.adobe.pdf"
        // Currently, Preview itself gives option to share
        pdfShareHelper.presentPreview(animated: false)
    }
    
    func loadImageButtonPushed() {
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            let alert = UIAlertController(title: "Choose a Photo", message: nil, preferredStyle: UIAlertControllerStyle.alert)
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
    
    func feedbackButtonTapped() {
        let svc = SFSafariViewController(url: NSURL(string: "https://docs.google.com/forms/d/e/1FAIpQLScW_-4-4PmJdlqe0aV45IIZTJqL8fvW90f60-H7BI82sdja6A/viewform?usp=sf_link") as! URL)
        self.present(svc, animated: true, completion: nil)
    }
    
    func clearButtonTapped() {

        workView.clear()
    }
    
    func penSizeChanged(to: CGFloat) {
        workView.changePenSize(to: to)
    }
    
    func penColorChanged(to: SelectedPenColor) {
        workView.changePenColor(to: to)
    }
    
    func changePaper(to: SelectedPaperType){
        workViewPresenter.changePaper(to: to)
    }

    func didRequestWRDisplay(query: String){
        let newQuery = query.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let svc = SFSafariViewController(url: NSURL(string: "https://www.wolframalpha.com/input/?i=" + newQuery) as! URL)
        self.present(svc, animated: true, completion: nil)
    }
    
    //MARK: GKImagePickerController Delegate
    @objc func imagePicker(_ imagePicker: GKImagePicker,  pickedImage: UIImage) {
        dismiss(animated: true, completion: nil)
        workViewPresenter.addImageToCurrentPageInWorkView(pickedImage)
    }
    
    override func didReceiveMemoryWarning() {
        workViewPresenter.freeInactivePages()
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Various Support functions
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    public func displayErrorInViewController(title: String, description : String){
        let alertController = UIAlertController(title: title, message:
            description, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
