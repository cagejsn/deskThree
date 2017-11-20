//
//  FileSystemInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Zip

enum Change {
    case MovedBlock
    case AddedStroke
    case AddedImage
    case CreatedNewPage(atIndex: Int)
    case DeletedGrouping
    case RenamedGrouping(newName: String)
    case CreatedGrouping
    case RenamedProject(newName: String)
    case MovedProject(destGroupingName: String)
    case DeletedProject
    case CreatedProject
}

enum DeskFileSystemError: Error {
    case FileNameIsTakeDuringRenameOperation(String)
    case ProjectNameTakenInGrouping(String)
    case NoGroupingMetaFileWithName(String)
    case NeededDirectoryIsMissing
}


class FileSystemInteractor: NSObject {
    
    var metaDataInteractor: MetaDataInteractor?
    var projectFileInteractor: ProjectFileInteractor?
    
    
    func handle( _ change: Change, page: inout Paper){
        switch (change){
        
        case .MovedBlock:
            
            break
            
            
        case .AddedStroke:
            
            break
            
            
        case .AddedImage:
            
            break
            
            
        default:
            abort()
            break
        }
        
    }
    
    func handle( _ change: Change, project: inout DeskProject , page: inout Paper){
        
    }

    
    
    func handle(_ change: Change, grouping: inout Grouping, project: inout DeskProject, page: inout Paper){
        
        switch(change){
            
        case .CreatedNewPage(let atIndex):
            
            
            break
            
    
        
     
        
        case .MovedProject(let destinationGroupingName):
            do{
                try MetaDataInteractor.save(project: &project, intoGroupingWithName: destinationGroupingName)
                try MetaDataInteractor.remove(project: project, from: &grouping)
            } catch let error {
                print(error.localizedDescription)
            }
            break
            
            
        case .DeletedProject:
            try! MetaDataInteractor.remove(project: project, from: &grouping)

            break
            
            
      
        
        default:
            abort()
            break
            
        }
        
        
    }
    
    func handle( _ change: Change, grouping: inout Grouping, project: inout DeskProject){
        switch change {
            
        case .CreatedProject:
            MetaDataInteractor.save(project: &project, into: &grouping)
            break
            
         
        case .RenamedProject(let newName):
            do{
                try MetaDataInteractor.rename(project: &project, to: newName, in: &grouping)
            } catch let error {
                print(error.localizedDescription)
            }
            break
            
        default:
            abort()
            break
        }
    }
    
    func handle( _ change: Change, grouping: inout Grouping){
        
        switch (change){
        case .DeletedGrouping:
            MetaDataInteractor.remove(grouping: grouping)
            break
        
        
        case .RenamedGrouping(let newName):
            do {
                try MetaDataInteractor.rename(grouping: &grouping, to: newName)
            } catch let error {
                print(error.localizedDescription)
            }
            break
        
        
        case .CreatedGrouping:
            do {
                try MetaDataInteractor.saveMetaData(of: grouping)
            } catch let error {
                print(error.localizedDescription)
        }
            break
        
        default:
            //not found
            //mix of overloaded parameters and cases
            abort()
            break
        }
    } //end of function
    
    
    static func getMetaData() -> [Grouping] {
        
        let groupings = MetaDataInteractor.retrieveAllGroupingMetaData()
        return groupings
    }
    
    /// dont call this yet
    static func zipProjectFromTempFolderAndPlaceInGroupingFolder(project: DeskProject, grouping: Grouping) throws -> String  {
        let tempFolderPath = PathLocator.getTempFolder()
        let fileManager = FileManager.default
        let projectFolderPathInTemp = tempFolderPath + "/" + project.getName()
        var isDirectoryBool: ObjCBool = ObjCBool(false)
        
        let groupingFolder = PathLocator.getProjectsFolderFor(groupingName: grouping.getName())

        if(!fileManager.fileExists(atPath: projectFolderPathInTemp, isDirectory: &isDirectoryBool)) {
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }
        if(!fileManager.fileExists(atPath: groupingFolder, isDirectory: &isDirectoryBool)){
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }
        if (!isDirectoryBool.boolValue){
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }

        // now we know that there are two DIRECTORIES, one is the project Folder in TEMP
        // which we will zip and the other is the Grouping's Folder where the zipped projects live
        
        
        
      //  let documentPath2 = tempFolderPath + "/" + "UntitledCAGE"

        
//        var directoryBool: ObjCBool = ObjCBool(false)

       
        let zipFilePath =  URL(fileURLWithPath: groupingFolder).appendingPathComponent("archive.zip")
        
        
        if (fileManager.fileExists(atPath: documentPath, isDirectory: &directoryBool)){
            try! Zip.zipFiles(paths: [URL(fileURLWithPath:documentPath)], zipFilePath: zipFilePath , password: nil, progress: nil)
        }
        
        
        
        try! Zip.unzipFile(zipFilePath, destination: URL(fileURLWithPath:documentPath2), overwrite: true, password: nil, progress: nil)
        
        
        return documentPath
        
    }
    
    /*
    //needs to which project is in temp and  also which grouping we are talking about
    static func takeTempAndStoreProjectinitpersistentfolder(){
        //this shouldn't be a meta data operation , i think
        //is this project in the Temp Folder?
       
        let isinTemp: Bool = ProjectFileInteractor.isInTemp(project: DeskProject)
        
        if(!isInTemp){
            abort()
        }
        
        //project is in temp
        ProjectFileInteractor.zipAndPlaceInGroupingProjectFolder(project)

    }
    
    static func getProjectAndOpenIntoTemp(project: DeskProject, grouping: Grouping){
        
        
        //1. find the project in the grouping folder
        ProjectFileInteractor.load(project)
    
    }
    
    //should this have the capacity to ccreate a Page if the desired PageNo doesn't exist?
    static func getMeThePageWhichIwantWhichIsinTemp(Grouping, Project, PageNo)-> Paper
    */
    
    
    
}
