//
//  MetaDataInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation



class MetaDataInteractor: NSObject {
    
    static func rename(grouping: inout Grouping, to newName: String) throws  {
        let fileManager = FileManager.default
        let metaFolderPath = PathLocator.getMetaFolder()
        let currentPathOfGroupingMetaData = metaFolderPath + "/" + grouping.getName() + ".meta"
        let newPathForGroupingMetaData = metaFolderPath + "/" + newName + ".meta"
        if(fileManager.fileExists(atPath: newPathForGroupingMetaData)){
            //there is already a file at this path
            //throw an error
            throw DeskFileSystemError.FileNameIsTakeDuringRenameOperation(newName)
            return
        }
        
        //if newName isn't the right kind of string?
        grouping.rename(name: newName)
        
        //this may not work
        try! fileManager.copyItem(atPath: currentPathOfGroupingMetaData, toPath: newPathForGroupingMetaData)
        
        try! fileManager.removeItem(atPath: currentPathOfGroupingMetaData)
        
    }
   
    
    static func rename(project: inout DeskProject, to newName: String, in grouping: inout Grouping) throws {
        let projectName = project.getName()
        let groupingName = grouping.getName()
        var projects = grouping.getProjects()!
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        
        for i in 0..<projects.count{
            if (projects[i].getName() == projectName) {
                //raise dialog asking user confirmation to overwrite
                //throw DeskFileSystemError.ProjectWouldBeOverwritten(projectName)
                project.rename(name: newName)
             //   projects[i] = project
             //   grouping.projects = projects
                try! saveMetaData(of: grouping)
                return
            }
        }
        //failure
    }
    
    static func remove(grouping: Grouping){
        let fileManager = FileManager.default
        let groupingName = grouping.getName()
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        do{
            try fileManager.removeItem(atPath: filePath)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func remove(project: DeskProject, from grouping: inout Grouping){
        let projectName = project.getName()
        let groupingName = grouping.getName()
        var projects = grouping.getProjects()!
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        
        for i in 0..<projects.count{
            if (projects[i].getName() == projectName) {
                //raise dialog asking user confirmation to overwrite
                projects[i] = project
                projects.remove(at: i)
                grouping.projects = projects
                try! saveMetaData(of: grouping)
                return
            }
        }
        //failure
    }
    
    static func save(project: inout DeskProject, intoGroupingWithName groupingName: String) throws {
        let fileManager = FileManager.default
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        
        if(!fileManager.fileExists(atPath: filePath)){
            //no Grouping with destination name
            throw DeskFileSystemError.NoGroupingMetaFileWithName(groupingName)
        }
        let grouping = NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
        if let grouping = grouping as! Grouping! {
            grouping.addProject(project)
            try! saveMetaData(of: grouping)
        }
      

        //ignores the files folder implications and only does the meta data rn
    }
    
    static func save(project: inout DeskProject, into grouping: inout Grouping){
        let projectName = project.getName()
        let groupingName = grouping.getName()
        var projects = grouping.getProjects()!
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        
        for i in 0..<projects.count{
            if (projects[i].getName() == projectName) {
                //raise dialog asking user confirmation to overwrite
                projects[i] = project
                grouping.projects = projects
                try! saveMetaData(of: grouping)
                return
            }
        }
        projects.append(project)
        grouping.projects = projects
        try? saveMetaData(of: grouping)
        
    }
    
    ///saves metadata of a grouping to meta file. overwrite same name if present
    static func saveMetaData(of grouping: Grouping) {
        let fileManager = FileManager.default
        let name = grouping.getName()
        let filePath = PathLocator.getMetaFolder()+"/"+name+".meta"
        if(fileManager.fileExists(atPath: filePath)){
            //there is already a file at this path
            //throw an error
            //throw DeskFileSystemError.FileNameIsTakeDuringRenameOperation(name)
        }
        NSKeyedArchiver.archiveRootObject(grouping, toFile: filePath)
    }
    
    
    static func retrieveAllGroupingMetaData() -> [Grouping] {
        let fileManager = FileManager.default
        let metaFolderPath = PathLocator.getMetaFolder()
        let groupingNamesAsString = try! fileManager.contentsOfDirectory(atPath: metaFolderPath)
        var groupings: [Grouping] = [Grouping]()
        for groupingName in groupingNamesAsString {
            if let grouping = NSKeyedUnarchiver.unarchiveObject(withFile: metaFolderPath + "/" + groupingName) as? Grouping! {
                groupings.append(grouping)
            }
        }
        return groupings
    }
    
}
