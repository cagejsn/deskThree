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
    case MissingDZIPFileWithProjectContents
    case ProjectDirectoryAlreadyExistsInTemp
}


class FileSystemInteractor: NSObject {
    
    var metaDataInteractor: MetaDataInteractor?
    var projectFileInteractor: ProjectFileInteractor?
    
    
    func handle( _ change: Change, grouping: inout Grouping, project: inout DeskProject, page: inout Paper){
        switch (change){
        
        case .MovedBlock:
            FileSystemInteractor.archivePageObjectsIntoTempFolder(for: page, project: project)
            break
            
        case .AddedStroke:
            FileSystemInteractor.archiveJotView(for: page, project: project)
            break
            
            
        case .AddedImage:
            FileSystemInteractor.archivePageObjectsIntoTempFolder(for: page, project: project)
            break
            
        case .CreatedNewPage(let atIndex):
            //TODO add logic for inserting a page in the middle of a document
            //
            FileSystemInteractor.getPageDirectoryInTempFor(pageNo: atIndex, in: project)
            
            break
            
    
        
     
        
        case .MovedProject(let destinationGroupingName):
            
            //TODO go find the .zip file of the project and literally put it somewhere
            
            //now the meta data change
            do{
                try MetaDataInteractor.save(project: &project, intoGroupingWithName: destinationGroupingName)
                try MetaDataInteractor.remove(project: project, from: &grouping)
            } catch let error {
                print(error.localizedDescription)
            }
            break
            
            
        case .DeletedProject:
            
            //TODO: remove the .zip file from the Grouping's folder
            try! MetaDataInteractor.remove(project: project, from: &grouping)

            break
            
            
   
            
        case .CreatedProject:
            
            //TODO: hmm should we add a .zip into
            
            MetaDataInteractor.save(project: &project, into: &grouping)
            break
            
         
        case .RenamedProject(let newName):
            do{
                try MetaDataInteractor.rename(project: &project, to: newName, in: &grouping)
            } catch let error {
                print(error.localizedDescription)
            }
            break
            
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
    /*
    static func findAndLoad(project: String,in grouping: String, to page: Int, ){
        
        
    }
*/
    
    static func afterLoading(pageNo: Int, inProject: String, fromGrouping: String, run loadingCompletionBlock: (inout Grouping,inout DeskProject,inout Paper) -> ()){
        
        var grouping = MetaDataInteractor.getGrouping(withName: fromGrouping)
        let groupingProjects = grouping!.projects!
        
        var seekForProject: DeskProject?
        for project in groupingProjects {
            if project.getName() == inProject{
            seekForProject = project
            break
            }
        }
        
        //go get the zipped file of the same name as the DeskProject which will be in this Grouping's folder, load that thing in to the Temp Folder
        try! getProjectFilesFromGroupingAndThenUnzipIntoTemp(project: seekForProject!, grouping: grouping!)
        
        //now we can look for the specified PageNo and return the unarchived Paper if we find it
        
        let pathToDesiredPageFolder = getPageDirectoryInTempFor(pageNo: pageNo, in: seekForProject!)
        
        let pathToArchivedPaperObject = pathToDesiredPageFolder + "/page.desk"
        var data = NSKeyedUnarchiver.unarchiveObject(withFile: pathToArchivedPaperObject)
        
        if var paper = data as! Paper! {
            loadingCompletionBlock(&grouping!, &seekForProject!, &paper)
        }
    }
    
    
    static func getMetaData() -> [Grouping] {
        
        let groupings = MetaDataInteractor.retrieveAllGroupingMetaData()
        return groupings
    }
    
    static func getProjectDirectoryInTemp(project: DeskProject) -> String {
        
        let path = try! ProjectFileInteractor.makeProjectDirectoryInTemp(withName: project.getName())
        return path
    }
    
    static func getPageDirectoryInTempFor(pageNo: Int, in project: DeskProject)-> String {
        let fileManager = FileManager.default
        let projectDirInTemp = getProjectDirectoryInTemp(project: project)
        let proposedPageDir = projectDirInTemp + "/page" + String(pageNo)
        
        var isDirBool: ObjCBool = ObjCBool(false)
        
        if(fileManager.fileExists(atPath: proposedPageDir, isDirectory: &isDirBool)){
            return proposedPageDir
        }
        
        //going to make a new directory for the proposed page        
        //first we will use a while loop to get the lowest pageNo. that isn't taken
        var i = 1
        while(fileManager.fileExists(atPath: projectDirInTemp + "/page" + String(i))){
            i += 1
        }
        let calculatedPageDir = projectDirInTemp + "/page" + String(i)
        //check to make sure that the proposedPage Number Is the next available one
        if(proposedPageDir != calculatedPageDir){
//            we have a problem
            abort()
        }
            
        try! fileManager.createDirectory(atPath: proposedPageDir, withIntermediateDirectories: false, attributes: nil)
        
        return proposedPageDir
    }
    
    static func archivePageObjectsIntoTempFolder(for page: Paper, project: DeskProject){
        let pageDirectory = getPageDirectoryInTempFor(pageNo: page.getPageNumber(), in: project)
        NSKeyedArchiver.archiveRootObject(page, toFile: pageDirectory + "/page.desk")
    }
    
    static func archiveJotView(for page: Paper, project: DeskProject){
        let pageDirectory = getPageDirectoryInTempFor(pageNo: page.getPageNumber(), in: project)
        JotFilesInteractor.archiveJotView(forPage: page, in: project)
        
       // page.saveDrawing(at: pageDirectory)
        
    }
    
    
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
        
        let zipFilePath =  URL(fileURLWithPath: groupingFolder).appendingPathComponent(project.getName()+".zip")
      
        try! Zip.zipFiles(paths: [URL(fileURLWithPath:projectFolderPathInTemp)], zipFilePath: zipFilePath, password: nil, progress: nil)
        
        //what about overwrites?
        return groupingFolder + "/" + project.getName()
    }
    
    static func getProjectFilesFromGroupingAndThenUnzipIntoTemp(project: DeskProject, grouping: Grouping) throws {
        
        let tempFolderPath = PathLocator.getTempFolder()
        let fileManager = FileManager.default
       // let projectFolderPathInTemp = tempFolderPath + "/" + project.getName()
        var isDirectoryBool: ObjCBool = ObjCBool(false)
        
        let groupingFolder = PathLocator.getProjectsFolderFor(groupingName: grouping.getName())
        let projectFilePath = groupingFolder + "/" + project.getName() + ".zip"
        
        if(!fileManager.fileExists(atPath: groupingFolder, isDirectory: &isDirectoryBool)){
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }
        if (!isDirectoryBool.boolValue){
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }
        if (!fileManager.fileExists(atPath:projectFilePath)){
            throw DeskFileSystemError.MissingDZIPFileWithProjectContents
        }
        
     //   Zip.un
        //all good, lets unzip into a directory
        do {
             try Zip.unzipFile(URL(fileURLWithPath: projectFilePath), destination: URL(fileURLWithPath:tempFolderPath), overwrite: true, password: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
