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
    
    var currentGrouping: Grouping
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
