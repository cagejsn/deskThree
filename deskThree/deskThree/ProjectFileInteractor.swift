//
//  ProjectFileInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Zip

class ProjectFileInteractor: NSObject {
    
    var paperInteractor: PaperInteractor?

    
    func loadProjectIntoTempFolder(project: DeskProject){
        
    }
    
    
    func saveProject(){
        
    }
    
    static func unarchivePageFile(atPath path: String) throws -> Paper {
        let obj = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        guard let paper = obj as! Paper! else {
            throw DeskFileSystemError.DidntFindPaperAtPath
        }
        return paper
    }
    
    static func isFolderInTemp(project withName: String)-> Bool {
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
    
    static func isFolderIn( grouping: Grouping , with name: String) -> Bool {
        let groupingFolderPath = PathLocator.getProjectsFolderFor(groupingName: grouping.getName())
        let proposedProjectFolderPathInGrouping = groupingFolderPath + "/" + name
        let fileManager = FileManager.default
        var isDirectoryBool: ObjCBool = ObjCBool(false)
        if(fileManager.fileExists(atPath: proposedProjectFolderPathInGrouping, isDirectory: &isDirectoryBool)){
            if(!isDirectoryBool.boolValue){
                return false
            }
            return true
        }
        return false
    }
    
    static func renameProjectFolderInGroupingFolder(oldProjectName: String, newProjectName: String, in groupingName: String) throws {
        let fileManager = FileManager.default
        let pathToGroupingProjects = PathLocator.getProjectsFolderFor(groupingName: groupingName)
        
        let proposedNewPathToProject = pathToGroupingProjects + "/" + newProjectName
        let pathToSpecificProject = pathToGroupingProjects + "/" + oldProjectName
        
        let projectFolderLocation = URL(fileURLWithPath: pathToSpecificProject)
        let locationAfterRename = URL(fileURLWithPath: proposedNewPathToProject)
        
        do {
            try fileManager.moveItem(at: projectFolderLocation, to: locationAfterRename)
        } catch let e {
            do {
                try fileManager.replaceItemAt(locationAfterRename, withItemAt: projectFolderLocation)
            } catch let e {
                throw e
            }
        }
    }
    
    static func renameZipAndFolderInside(source: URL , dest: URL ) throws {
        do {
        var topLevelfolder = try Zip.quickUnzipFile(source)
        var urls = try FileManager.default.contentsOfDirectory(at: topLevelfolder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let folder = urls.first!
        let tempURL = dest.deletingPathExtension()
        let newName = tempURL.lastPathComponent
        var tempFolderWithRename = folder.deletingLastPathComponent()
        tempFolderWithRename.appendPathComponent(dest.deletingPathExtension().lastPathComponent)
        try FileManager.default.moveItem(at: folder, to: tempFolderWithRename)
        try Zip.zipFiles(paths: [tempFolderWithRename], zipFilePath: dest, password: nil, progress: nil)
        try FileManager.default.removeItem(at: topLevelfolder)
        try FileManager.default.removeItem(at: source)
        }
        
    }
    
    static func renameProjectDirectoryInTemp(oldName: String, newName: String) throws {
        let tempFolderPath = PathLocator.getTempFolder()
        let fileManager = FileManager.default
        let sourcePath = tempFolderPath+"/"+oldName
        let destPath = tempFolderPath+"/"+newName
        
        do {
            try fileManager.moveItem(atPath: sourcePath, toPath: destPath)
        } catch let e {
            do {
                try fileManager.replaceItemAt(URL(fileURLWithPath: destPath), withItemAt: URL(fileURLWithPath: sourcePath))
            } catch let e {
                throw e
            }
        }
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
    
    static func removeProjectDirectoryFrom(_ grouping: Grouping, project: DeskProject) throws {
        let fileManager = FileManager.default
        
        do{
            let urlToRemove = try getURLofFolderForProjectInGroupingsFile(in: grouping, project: project)
            try fileManager.removeItem(at: urlToRemove)
        } catch let e {
            throw e
        }
    }
    
    static func getURLofFolderForProjectInGroupingsFile(in grouping: Grouping, project: DeskProject) -> URL {
        let fileManager = FileManager.default
        let projectsFolderPath = PathLocator.getProjectsFolderFor(groupingName: grouping.getName())
        let proposedProjectFolderPath = projectsFolderPath + "/" + project.getName()
        return URL(fileURLWithPath: proposedProjectFolderPath)        
    }
    
}
