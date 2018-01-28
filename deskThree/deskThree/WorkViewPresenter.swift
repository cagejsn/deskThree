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
    var selectedPaperType: SelectedPaperType = .graph
    
    var currentGrouping: Grouping = MetaDataInteractor.getDefaultGrouping()
    var currentProject: DeskProject!
    var currentPage: Paper!
    var fileSystemInteractor: FileSystemInteractor!
    
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
    
    func toggleClipping(_ sender: UIButton){
        if(sender.isSelected){
            currentPage.clipperSession.end()
            currentPage.clipperSession = nil
        } else {
            currentPage.clipperSession = ClipperSession(sender, currentPage)
            currentPage.clipperSession.start()
        }
        AnalyticsManager.track(.MagicWand)
    }
    
    func undo(){
        currentPage.drawingView.undo()
        AnalyticsManager.track(.UndoStroke)
    }
    
    func redo(){
        currentPage.drawingView.redo()
        AnalyticsManager.track(.RedoStroke)
    }
    
    //TODO: implement
    /**
     Move to a page to the right
     If there is no page, add one and make it the current page
     */
    func movePage(direction: String) {
        workView.prepareForAnIncomingPage()
        if direction  == "right" {
            movePageRight()
        } else if direction == "left" {
            movePageLeft()
        }
        updatePageLabels()
    }
    
    func movePageRight(){
        if(!isProjectEdited()){handleFirstProjectEdit()}
        if(!isPageEdited()){handleFirstPageEdit()}
        // Check if this is the last page
        if currentPage.getPageNumber() == pages.count {
            dismissCurrentPage()
            moveToNewPage()
        } else {
            dismissCurrentPage()
            loadExistingPageAt(pageNo: currentPage.getPageNumber() + 1)
        }
        
        AnalyticsManager.track(.PageRight)
    }
    
    func movePageLeft(){
        // Check if this is the first page
        if currentPage.getPageNumber() > 1 {
            dismissCurrentPage()
            loadExistingPageAt(pageNo: currentPage.getPageNumber() - 1)
        }
        AnalyticsManager.track(.PageLeft)
    }
    
    func updatePageLabels(){
        let currentPageNo = currentPage.getPageNumber()
        let totalPageNo = pages.count
        workView.updatePageNotification(onPage: currentPageNo, ofTotalPages: totalPageNo)
        updateDVCPageLabelHandler!(currentPageNo,totalPageNo)
    }
    
    func moveToNewPage(){
        // Add a new page
        var paper = Paper(pageNo: currentPage.getPageNumber()+1, workViewPresenter: self)
        pages.append(paper)
        paper.setBackground(to: selectedPaperType)
        
        // Push back the old view
        workView.sendSubview(toBack: currentPage)
        
        // Bring forward the new view
        currentPage = paper
        
        workView.acceptAndConfigure(page: currentPage)
        
        let change = PaperChange.CreatedNewPage(atIndex: currentPage.getPageNumber())
        fileSystemInteractor.handlePaper(change: change, grouping: currentGrouping, project: currentProject, page: currentPage)
        currentPage.connectNewDrawingViewToPage()
    }
    
    func dismissCurrentPage(){
        discardPathsToJotElements()
        currentPage.drawingView.removeFromSuperview()
        currentPage.drawingSession.endSession()
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
        workView.acceptAndConfigure(page: currentPage)
    }
    
   
    
    func renameProject(_ newName: String) -> Bool {
        if(!isProjectEdited()){handleFirstProjectEdit()}
        if(!isPageEdited()){handleFirstPageEdit()}
        if(newName == currentProject.getName()){return true}
        let change = MetaChange.RenamedProject(newName: newName, isOpen: true)
        return fileSystemInteractor.handleMeta(change, grouping: currentGrouping, project: currentProject)
    }
    
    func addImageToCurrentPageInWorkView(_ image: UIImage){
        if(!isProjectEdited()){handleFirstProjectEdit()}
        if(!isPageEdited()){handleFirstPageEdit()}
        currentPage.addImageBlock(pickedImage: image)
        let change = PaperChange.MovedImage
        fileSystemInteractor.handlePaper(change: change, grouping: currentGrouping, project: currentProject, page: currentPage)
    }
    
    func strokeWasAdded(_ change: PaperChange){
        if(!isProjectEdited()){handleFirstProjectEdit()}
        if(!isPageEdited()){handleFirstPageEdit()}
        fileSystemInteractor.handlePaper(change: change, grouping: currentGrouping, project: currentProject, page: currentPage)
    }
    
    func blockWasMoved(_ change: PaperChange){
        if(!isProjectEdited()){handleFirstProjectEdit()}
        if(!isPageEdited()){handleFirstPageEdit()}
        fileSystemInteractor.handlePaper(change: change, grouping: currentGrouping, project: currentProject, page: currentPage)
    }
    
    func loadNewProject(){
        workView.acceptAndConfigure(page: currentPage)
    }
    
    func handleFirstProjectEdit(){
        currentProject.edit()
        fileSystemInteractor.handleFirstProjectEdit(grouping: currentGrouping, project: currentProject, page: currentPage)
    }
    
    func handleFirstPageEdit(){
        currentPage.edit()
        fileSystemInteractor.handleFirstPageEdit(project: currentProject, page: currentPage)
        makePathsForJVSPD_Duties()
    }
    
    func discardPathsToJotElements(){
        jotViewStateInkPath = ""
        jotViewStatePlistPath = ""        
    }
    
    // Called before loading a new project
    private func cleanUpPages() {
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
        fileSystemInteractor.afterLoading(pageNo: toPage, inProject: project.getName(), fromGrouping: grouping.getName(), run: loadHandler)
        
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
      
        if(isProjectEdited()){
            //if the project was edited in this session
            //it needs to be saved
            do {
                //clean out the TempFolder
                try fileSystemInteractor.moveProjectFromTempFolderAndPlaceInGroupingFolder(project: currentProject, grouping: currentGrouping)
            } catch let e {
                fileSystemInteractor.showMessageFor(e)
            }
        }
    }
    
    
    //maintains current grouping
    func newProjectRequested(in updatedGrouping: Grouping?){
        closeProject()
        if(updatedGrouping != nil){
            currentGrouping = updatedGrouping!
        }
        self.currentProject = MetaDataInteractor.makeNewProjectOfFirstAvailableName(in: currentGrouping)
        currentPage = Paper(pageNo: 1, workViewPresenter: self)
        replacePagesWithEmptyArray()
        pages.append(currentPage)
        currentPage.setBackground(to: selectedPaperType)
        workView.acceptAndConfigure(page: currentPage)
    }
    
    func isPageEdited() -> Bool {
        return currentPage.isEdited
    }
    
    func isProjectEdited() -> Bool {
        return currentProject.isEdited
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
    
    
    func getOpenProjectPageThumbnails() -> [UIImage]{
        
        let fileManager = FileManager.default
        var arrayOfPageImages = [UIImage]()
        
        for page in pages {
        let pathToPageFolder = fileSystemInteractor.getPageDirectoryInTempFor(pageNo: page!.getPageNumber(), in: currentProject)
            do {
                let contentsAsStrings = try! fileManager.contentsOfDirectory(atPath: pathToPageFolder)
                if contentsAsStrings.contains("thumb.png"){
               arrayOfPageImages.append(UIImage(contentsOfFile: pathToPageFolder + "/thumb.png")!)
                }
            }
        }
        return arrayOfPageImages
    }
    
    func exportPDF (to pdfData: NSMutableData) -> Bool {
        
        UIGraphicsBeginPDFContextToData(pdfData, currentPage.bounds, nil)
        
        let thumbs = getOpenProjectPageThumbnails()
        for (index, page) in pages.enumerated() {
            
            let rect = page?.bounds
            UIGraphicsBeginPDFPageWithInfo(rect!, nil)
            guard let pdfContext = UIGraphicsGetCurrentContext() else { return false}
            page?.isHidden = false
            let useful = UIImageView(frame: CGRect(x: 0, y: 0, width: 1275, height: 1650))
            useful.image = thumbs[index]
            //TODO: fix print when there is no file around to print
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
    
    
    //TODO: make the Project only get zipped and written to disk upon closing if it has edits
    init(_ viewController: UIViewController) {
        super.init()
        self.currentProject = MetaDataInteractor.makeNewProjectOfFirstAvailableName(in: currentGrouping)
        self.currentPage = Paper(pageNo: 1, workViewPresenter: self )
        self.pages.append(currentPage)
        fileSystemInteractor = FileSystemInteractor(viewController)
        do {
            DispatchQueue.main.async {
                try? self.fileSystemInteractor.saveLostState()
            }
        } catch let e {
            print(e.localizedDescription)
        }
        
        
    }
}
