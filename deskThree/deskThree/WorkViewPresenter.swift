//
//  WorkViewPresenter.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class WorkViewPresenter: NSObject {
    
    private var pages: [Paper?] = [Paper]()
    
    var currentGrouping: Grouping!
    var currentProject: DeskProject!
    var currentPage: Paper!
    
    var fileSystemInteractor: FileSystemInteractor!
    
    
    
    
    
    
    
    func somethingChanged(){
        
        let loadingBlock: (inout Grouping, inout DeskProject,inout Paper) -> () = { value1, value2, value3 in
            self.currentGrouping = value1
            self.currentProject = value2
            self.currentPage = value3
        }
        
        
     
        
        
        var myPage = Paper()
        var firstGrouping = Grouping()
        var project3 = DeskProject(name: "cage  ")
        let change1: Change = .CreatedGrouping
        fileSystemInteractor.handle(change1, grouping: &firstGrouping, project: &project3, page:&myPage)
      
        
        var project = DeskProject(name: "zzz")
        let change2: Change = .CreatedProject
        fileSystemInteractor.handle(change2, grouping: &firstGrouping, project: &project, page:&myPage)
        
        try! FileSystemInteractor.zipProjectFromTempFolderAndPlaceInGroupingFolder(project: project, grouping: firstGrouping)
        
        //this is a way to get a Project into the Temp Folder AND load a desired Page into our Paper property
     FileSystemInteractor.afterLoading(pageNo: 1, inProject: "zzz", fromGrouping: "default", run: loadingBlock)
        
        
        
        
        
        
        let change3: Change = .RenamedGrouping(newName:"hello314")
        fileSystemInteractor.handle(change3, grouping: &firstGrouping, project: &project3, page:&myPage)
        
        let change4: Change = .RenamedProject(newName: "goodbye321")
        fileSystemInteractor.handle(change4, grouping: &firstGrouping, project: &project3, page:&myPage)
        
        let groupings = FileSystemInteractor.getMetaData()
        
        
     //   FileSystemInteractor.makeNewProjectDirectoryInTemp(project: project)
        let path = try! FileSystemInteractor.zipProjectFromTempFolderAndPlaceInGroupingFolder(project: project, grouping: firstGrouping)
        try! FileSystemInteractor.getProjectFilesFromGroupingAndThenUnzipIntoTemp(project: project, grouping: Grouping(name: "hello314"))
        
        print(firstGrouping.getName())
        
        for project in firstGrouping.getProjects()!{
        print(project.getName())
        }
       
    
    }
    
    override init() {
        self.fileSystemInteractor = FileSystemInteractor()
    }
}
