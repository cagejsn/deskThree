//
//  ProjectFileInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class ProjectFileInteractor: NSObject {
    
    var paperInteractor: PaperInteractor?

    
    func loadProjectIntoTempFolder(project: DeskProject){
        
    }
    
    
    func saveProject(){
        
    }
    
    static func isOpenInTemp(project withName: String)-> Bool {
        let tempFolderPath = PathLocator.getTempFolder()
        let proposedProjectFolderPathInTemp = tempFolderPath + "/" + withName
        let fileManager = FileManager.default
        var isDirectoryBool: ObjCBool = ObjCBool(false)
        if( fileManager.fileExists(atPath: proposedProjectFolderPathInTemp, isDirectory: &isDirectoryBool)){
            if(!isDirectoryBool.boolValue){
                return false
            }
            return true
        }
        return false
    }
    
    static func renameProjectZipInGroupingFolder(oldProjectName: String, newProjectName: String, in groupingName: String) {
        let fileManager = FileManager.default
        let pathToGroupingProjects = PathLocator.getProjectsFolderFor(groupingName: groupingName)
        let proposedNewPathToProject = pathToGroupingProjects + "/" + newProjectName + ".zip"
        let pathToSpecificProject = pathToGroupingProjects + "/" + oldProjectName + ".zip"
        if(!fileManager.fileExists(atPath: pathToSpecificProject)){
            abort() //invalid state
        }
        try! FileManager.default.moveItem(atPath: pathToSpecificProject, toPath: proposedNewPathToProject)
    }
    
    static func renameProjectDirectoryInTemp(oldName: String, newName: String){
        let tempFolderPath = PathLocator.getTempFolder()
        try! FileManager.default.moveItem(atPath: tempFolderPath+"/"+oldName, toPath: tempFolderPath+"/"+newName)
    }
    
    static func makeProjectDirectoryInTemp(withName: String) throws -> String {
        
        let tempFolderPath = PathLocator.getTempFolder()
        let proposedProjectFolderPathInTemp = tempFolderPath + "/" + withName
        let fileManager = FileManager.default
        var isDirectoryBool: ObjCBool = ObjCBool(false)
        if( fileManager.fileExists(atPath: proposedProjectFolderPathInTemp, isDirectory: &isDirectoryBool)){
//            throw DeskFileSystemError.ProjectDirectoryAlreadyExistsInTemp
            return proposedProjectFolderPathInTemp
        }
        
        try! fileManager.createDirectory(atPath: proposedProjectFolderPathInTemp, withIntermediateDirectories: false, attributes: nil)
        
        return proposedProjectFolderPathInTemp
    }
    
    
    
}
