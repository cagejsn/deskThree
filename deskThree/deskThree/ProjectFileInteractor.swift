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
