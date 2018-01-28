//
//  PaperInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class PaperInteractor: NSObject {
    
    var jotFilesInteractor: JotFilesInteractor?
    
    static func save(paper: Paper, in project: DeskProject, in grouping: Grouping){
        createNewPageDirectoryIfNeededInTemp(for: paper.getPageNumber(), in: project, in: grouping)
        archivePageObjects(for: paper, in: project)
        JotFilesInteractor.saveDrawing(for: paper, in: project)
    }
    
    static func createNewPageDirectoryIfNeededInTemp(for pageNo: Int, in project: DeskProject, in grouping: Grouping) {
        let groupingName = grouping.getName()
        let projectName = project.getName()
        let pageDir = PathLocator.getTempFolder()+"/"+projectName+"/page"+String(pageNo)
        do{
            try FileManager.default.createDirectory(atPath: pageDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("dir for page already exists")
        }
    }
    
    static func archivePageObjects(for page: Paper, in project: DeskProject){
        let pageFolder = PathLocator.getTempFolder() + "/" + project.getName() + "/page"+String(page.getPageNumber())
        NSKeyedArchiver.archiveRootObject(page, toFile: pageFolder + "/page.desk")
    }
}
