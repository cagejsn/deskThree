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
    
    var currentGrouping: Grouping?
    var currentProject: DeskProject!
    var currentPage: Paper!
    
    var fileSystemInteractor: FileSystemInteractor!
    
    
    func somethingChanged(){
        
        
        
        var firstGrouping = Grouping()
        let change1: Change = .CreatedGrouping
        fileSystemInteractor.handle(change1, grouping: &firstGrouping)
        
        
        var project = DeskProject(name: "cage")
        let change2: Change = .CreatedProject
        fileSystemInteractor.handle(change2, grouping: &firstGrouping, project: &project)
        
        
        let change3: Change = .RenamedGrouping(newName:"hello314")
        fileSystemInteractor.handle(change3, grouping: &firstGrouping)
        
        let change4: Change = .RenamedProject(newName: "goodbye321")
        fileSystemInteractor.handle(change4, grouping: &firstGrouping, project: &project)
        
        let groupings = FileSystemInteractor.getMetaData()
        
        let path = try! FileSystemInteractor.zipProjectFromTempFolderAndPlaceInGroupingFolder()
        
        
        print(firstGrouping.getName())
        
        for project in firstGrouping.getProjects()!{
        print(project.getName())
        }
       
    
    }
    
    override init() {
        self.fileSystemInteractor = FileSystemInteractor()
    }
}
