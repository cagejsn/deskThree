//
//  WorkViewPresenter.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class WorkViewPresenter: NSObject, JotViewStateProxyDelegate, PencilEraserToggleControlDelegate {
    
    var jotViewStateInkPath: String!
    var jotViewStatePlistPath: String!
    
    private var pages: [Paper?] = [Paper]()
    var selectedPaperType: SelectedPaperType = .engineering
    
    private var currentGrouping: Grouping
    var currentProject: DeskProject
    lazy var currentPage: Paper = Paper(pageNo: 1, workViewPresenter: self)
    var fileSystemInteractor: FileSystemInteractor!
    
    var projectIsEdited: Bool = false
    var pageIsEdited: Bool = false
    
    var updateDVCPageLabelHandler: pageLabelHandler!
    typealias pageLabelHandler = (Int,Int)->()
    
    private var workView: WorkView!
    
    func setWorkView(_ workView: WorkView){
        self.workView = workView
    }
    
    func didLoadState(_ state: JotViewStateProxy!) {
        
    }
    
    func didUnloadState(_ state: JotViewStateProxy!) {
        
    }
    
    func switchTo(_ selected: SelectedWritingInstrument){
        workView.userSelected(writingInstrument: selected)
    }
    
    func beginClipping(){
        var clipper = Clipper(overSubview: currentPage)
        currentPage.addSubview(clipper)
        clipper.setCompletionFunction(functionToCall: clipperDidSelectMath)
    }
    
    var jotToMath: JotToMath!
    
    func aFunction(){
        var txt = jotToMath.resultAsText()
        if(txt == ""){ return }
        let mathimg1 = jotToMath.resultAsImage()
        if let mathimg2 = mathimg1 as? UIImage{
            let mathBlock = MathBlock(image: mathimg2, symbols: jotToMath.resultAsSymbolList(), text: jotToMath.resultAsText())
            // mathBlock.frame = CGRect(x: 100, y: 100, width: 200, height: 100)
            mathBlock.center = CGPoint(x: 200, y: 200)
            self.currentPage.addMathBlockToPage(block: mathBlock)
            
        }
    }
    
    func setUpJotToMath(pathFrame: CGRect){
        jotToMath = JotToMath()
        jotToMath.beautificationOption = .fontify
        jotToMath.frame = pathFrame
        // self.addSubview(jotToMath)
        jotToMath.setCompletionBlock(codeToRun: {[weak self] in return self?.aFunction()})
        
        let certificate: Data = NSData(bytes: myCertificate.bytes, length: myCertificate.length) as Data
        let certificateRegistered = jotToMath.registerCertificate(certificate)
        if(certificateRegistered){
            let mainBundle = Bundle.main
            var bundlePath = mainBundle.path(forResource: "resources", ofType: "bundle") as! NSString
            bundlePath = bundlePath.appendingPathComponent("conf") as NSString
            jotToMath.addSearchDir(bundlePath as String)
            jotToMath.configure(withBundle: "math", andConfig: "standard")
        }
    }
    
    func acceptClippedStrokes(strokes: [[MAWCaptureInfo]]){
        for stroke in strokes {
            jotToMath.addStroke(stroke)
        }
        jotToMath.solve()
    }
    
    func clipperDidSelectMath(selection: CGPath){
        setUpJotToMath(pathFrame: selection.boundingBox)
        
        let dict = NSDictionary(contentsOfFile: jotViewStatePlistPath)
        let importantPath = jotViewStatePlistPath.replacingOccurrences(of: "/state.plist", with: "")
        
        var folderContents = [String]()
        do{
         folderContents = try FileManager.default.contentsOfDirectory(atPath: importantPath)
        } catch(let e) {
            print(e.localizedDescription)
            
        }
        var arrayOfStrokes = [JotStroke]()
        for string in folderContents {
            if let string = string as? String {
                if string.contains(".strokedata") {
                    let s = JotStroke(lightFromDict: NSDictionary(contentsOfFile: importantPath+"/"+string) as! [AnyHashable : Any])
                    arrayOfStrokes.append(s!)
                }
            }
        }
        
        var output = [[MAWCaptureInfo]]()
        if let strokes = arrayOfStrokes as! [JotStroke]?{
            for strokeData in strokes {
                if let stroke = strokeData as JotStroke?{
                    var strokeForInput = [MAWCaptureInfo]()
                    if let segments = stroke.segments as! [AbstractBezierPathElement]?{
                        for segment in segments {
                            if let segment = segment as! AbstractBezierPathElement?{
                                var point = segment.startPoint
                                let drawSize = currentPage.drawingView.pagePtSize
                                
                                point.x = point.x * (1275 / drawSize.width)
                                point.y = (point.y * -(1650 / drawSize.height)) + 1650
                                
                                if(!selection.contains(point)){
                                    continue
                                } else {
                                    point = point - jotToMath.frame.origin
                                    var captured = MAWCaptureInfo()
                                    captured.x = Float(point.x)
                                    captured.y = Float(point.y)
                                    strokeForInput.append(captured)
                                }
                            }
                        }
                        output.append(strokeForInput)
                    }
                }
            }
        }
        acceptClippedStrokes(strokes: output)
    }
    
    //TODO: implement
    /**
     Move to a page to the right
     If there is no page, add one and make it the current page
     */
    func movePage(direction: String) {
        
        if direction  == "right" {
            if(!projectIsEdited){handleFirstProjectEdit(); projectIsEdited = true}
            if(!pageIsEdited){handleFirstPageEdit(); pageIsEdited = true}
            
            // Check if this is the last page
            if currentPage.getPageNumber() == pages.count {
                workView.prepareForAnIncomingPage()
                dismissCurrentPage()
                moveToNewPage()
            } else {
                workView.prepareForAnIncomingPage()
                dismissCurrentPage()
                loadExistingPageAt(pageNo: currentPage.getPageNumber() + 1)
            }
        } else if direction == "left" {
            // Check if this is the first page
            if currentPage.getPageNumber() > 1 {
                workView.prepareForAnIncomingPage()
                dismissCurrentPage()
                loadExistingPageAt(pageNo: currentPage.getPageNumber() - 1)
            }
        }
        
        currentPage.drawingView.currentPage = currentPage
        // Insert the new drawing view onto DeskView
      //  currentPage.subviewDrawingView()
        //        configurePage(page: &currentPage)
        
       updatePageLabels()
        
    }
    
    func updatePageLabels(){
        let currentPageNo = currentPage.getPageNumber()
        let totalPageNo = pages.count
        workView.updatePageNotification(onPage: currentPageNo, ofTotalPages: totalPageNo)
        updateDVCPageLabelHandler!(currentPageNo,totalPageNo)
    }
    
    func moveToNewPage(){
        pageIsEdited = false
        // Add a new page
        var paper = Paper(pageNo: currentPage.getPageNumber()+1, workViewPresenter: self)
        pages.append(paper)
        paper.setBackground(to: selectedPaperType)
        
        // Push back the old view
        workView.sendSubview(toBack: currentPage)
        
        // Bring forward the new view
        currentPage = paper
        
//        currentPage.setupDrawingView(withStateDelegate: self)
        workView.acceptAndConfigure(page: &currentPage)
        
        let change = PaperChange.CreatedNewPage(atIndex: currentPage.getPageNumber())
        FileSystemInteractor.handlePaper(change: change, grouping: &currentGrouping, project: &currentProject, page: &currentPage)
    }
    
    func dismissCurrentPage(){
        discardPageInfo()
        currentPage.drawingView.removeFromSuperview()
        currentPage.isHidden = true
    }
    
    //this should be the ultimate function to put a page on the screen
    // pre-requisites:
    // 1. the pages object has been loaded from disk
    // 2. the Project is in
    func loadExistingPageAt(pageNo: Int){
        currentPage = pages[pageNo - 1]!
        currentPage.isHidden = false
        makePathsForJVSPD_Duties()
        currentPage.setupDrawingView(withStateDelegate: self)
        workView.acceptAndConfigure(page: &currentPage)
    }
    
    func renameProject(_ newName: String) throws {
        if(!projectIsEdited){currentProject.rename(name: newName);return}
        if(newName == currentProject.getName()){return}
        let change = MetaChange.RenamedProject(newName: newName)
        do {
         try FileSystemInteractor.handleMeta(change, grouping: &currentGrouping, project: &currentProject)
        } catch let error {
            throw error
        }
    }
    
    func addImageToCurrentPageInWorkView(_ image: UIImage){
        if(!projectIsEdited){handleFirstProjectEdit(); projectIsEdited = true}
        if(!pageIsEdited){handleFirstPageEdit(); pageIsEdited = true}
        currentPage.addImageBlock(pickedImage: image)
        let change = PaperChange.AddedImage
        FileSystemInteractor.handlePaper(change: change, grouping: &currentGrouping, project: &currentProject, page: &currentPage)
    }
    
    func strokeWasAdded(_ change: PaperChange){
        if(!projectIsEdited){handleFirstProjectEdit(); projectIsEdited = true}
        if(!pageIsEdited){handleFirstPageEdit(); pageIsEdited = true}
        FileSystemInteractor.handlePaper(change: change, grouping: &currentGrouping, project: &currentProject, page: &currentPage)
    }
    
    func blockWasMoved(_ change: PaperChange){
        if(!projectIsEdited){handleFirstProjectEdit(); projectIsEdited = true}
        if(!pageIsEdited){handleFirstPageEdit(); pageIsEdited = true}
        FileSystemInteractor.handlePaper(change: change, grouping: &currentGrouping, project: &currentProject, page: &currentPage)
        
    }
    
    func loadNewProject(){
//        currentPage = Paper(pageNo: 1, workViewPresenter: self)
        workView.acceptAndConfigure(page: &currentPage)
    }
    
    //TODO: make the Project only get zipped and written to disk upon closing if it has edits
    override init() {        
        self.currentGrouping = MetaDataInteractor.getDefaultGrouping()
        self.currentProject = MetaDataInteractor.makeNewProjectOfFirstAvailableName(in: &currentGrouping)
        super.init()
        self.currentPage = Paper(pageNo: 1, workViewPresenter: self )
        self.pages.append(currentPage)
        
        FileSystemInteractor.emptyTempByZippingOpenProjects(into: &currentGrouping)
    }
    
    func handleFirstProjectEdit(){
        FileSystemInteractor.handleFirstProjectEdit(grouping: &currentGrouping, project: &currentProject, page: &currentPage)
    }
    
    func handleFirstPageEdit(){
        FileSystemInteractor.handleFirstPageEdit(project: &currentProject, page: &currentPage)
        makePathsForJVSPD_Duties()
    }
    
    func discardPageInfo(){
        jotViewStateInkPath = ""
        jotViewStatePlistPath = ""        
    }
    
    // Called before loading a new project
    private func cleanUpPages() {
        //        currentPage.drawingView.removeFromSuperview()
        for page in pages {
            page?.removePage()
        }
        pages.removeAll()
    }
    
    func openProject(project: DeskProject, grouping: Grouping, toPage: Int = 1){
        closeProject()
        
        var loadHandler: (inout Grouping, inout DeskProject,inout Paper, inout [Paper]) -> () = { grouping, project, paper, pages in
            self.currentGrouping = grouping
            self.currentProject = project
            self.currentPage = paper
            self.pages = pages
        }
        FileSystemInteractor.afterLoading(pageNo: toPage, inProject: project.getName(), fromGrouping: grouping.getName(), run: loadHandler)
        
        projectIsEdited = true
        pageIsEdited = true
        
        loadExistingPageAt(pageNo: toPage)
        updatePageLabels()
    }
    
    func makePathsForJVSPD_Duties(){
        self.jotViewStatePlistPath = PathLocator.getTempFolder()+"/"+currentProject.getName() + currentPage.jotViewStatePlistPath
        self.jotViewStateInkPath = PathLocator.getTempFolder() + "/" + currentProject.getName() + currentPage.jotViewStateInkPath
    }
    
    func closeProject(){
        workView.prepareForAnIncomingPage()
        currentPage.drawingView.removeFromSuperview()
        currentPage.removePage()
      
        if(projectIsEdited){
            //zip up project and store in the grouping folder
            try! FileSystemInteractor.zipProjectFromTempFolderAndPlaceInGroupingFolder(project: currentProject, grouping: currentGrouping)
            //clean out the TempFolder
            FileSystemInteractor.removeProjectFromTemp(project: currentProject)
        }
        projectIsEdited = false
        pageIsEdited = false
    }
    
    //maintains current grouping
    func newProjectRequested(){
        closeProject()
        self.currentProject = MetaDataInteractor.makeNewProjectOfFirstAvailableName(in: &currentGrouping)
        currentPage = Paper(pageNo: 1, workViewPresenter: self)
        replacePagesWithEmptyArray()
        pages.append(currentPage)
        currentPage.setBackground(to: selectedPaperType)
        workView.acceptAndConfigure(page: &currentPage)
    }
    
    //maintains current grouping
    func newProjectRequested(in grouping: Grouping){
        closeProject()
        self.currentGrouping = grouping
        self.currentProject = MetaDataInteractor.makeNewProjectOfFirstAvailableName(in: &currentGrouping)
        currentPage = Paper(pageNo: 1, workViewPresenter: self)
        replacePagesWithEmptyArray()
        pages.append(currentPage)
        currentPage.setBackground(to: selectedPaperType)
        workView.acceptAndConfigure(page: &currentPage)
    }
    
    
    func replacePagesWithEmptyArray(){
        pages.removeAll()
    }
    
    
    func freeInactivePages() {
        for i in 0..<pages.count {
            if(pages[i] != currentPage ){
                pages[i]?.removePage()
                pages.remove(at: i)
                pages.insert(nil, at: i)
            }
        }
    }
    
    func changePaper(to: SelectedPaperType){
        selectedPaperType = to
        for page in pages {
            page?.setBackground(to: selectedPaperType)
        }
    }
    
    func setupDelegateChain(){
        for page in pages {
            page?.delegate = workView
            page?.setupDelegateChain()
        }
    }
    
}
