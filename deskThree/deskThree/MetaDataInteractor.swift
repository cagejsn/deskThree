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
   
    
    //
    static func rename(project: inout DeskProject, to newName: String, in grouping: inout Grouping) throws {
        let projectName = project.getName()
        let groupingName = grouping.getName()
        var projects = grouping.getProjects()!
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        
        var desiredProjectNameIsTaken: Bool = false
        for i in 0..<projects.count{
            if (projects[i].getName() == newName) {
                desiredProjectNameIsTaken = true
            }
        }
        
        if(desiredProjectNameIsTaken){throw DeskFileSystemError.ProjectNameTakenInGrouping(newName)}
        project.rename(name: newName)
        try! saveMetaData(of: grouping)
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
        
        var projectNameIsTaken = true
        var attemptsToRename: Int = 0
        while(projectNameIsTaken){
            var i = 0
            while (i < projects.count){
                if (projects[i].getName() == project.getName()) {
                    attemptsToRename += 1
                    project.rename(name: projectName+"("+String(attemptsToRename)+")")
                    i = 0
                    continue
                }
                i += 1
            }
            projectNameIsTaken = false
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
    
    static func getGrouping(withName groupingName:String) throws -> Grouping? {
        let fileManager = FileManager.default
        let metaFolderPath = PathLocator.getMetaFolder()
        let proposedGroupingPath = metaFolderPath + "/" + groupingName + ".meta"
        if !fileManager.fileExists(atPath: proposedGroupingPath){
            throw DeskFileSystemError.NoGroupingMetaFileWithName(groupingName)
        }
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: proposedGroupingPath)
        if let grouping = data as! Grouping! {
            return grouping
        }
        return nil
    }
    
    static func getDefaultGrouping() -> Grouping{
        var defaultGrouping: String = "default"

//        defaultGrouping = UserDefaults.getDefaultGroupingName
        var grouping: Grouping
        do {
            grouping = try getGrouping(withName: defaultGrouping) as! Grouping!
        } catch let e {
            print(e.localizedDescription)
            grouping = Grouping(name: "default")
        }
        
        //set the user defaults defaultGrouping Name
//        UserDefaults.setDefaultGrouping
        
        return grouping
    }
    
    static func getSharedWithMeGrouping() -> Grouping{
        var defaultGrouping: String = "shared"
        
        var grouping: Grouping
        do {
            //grouping already exists
            grouping = try getGrouping(withName: defaultGrouping) as! Grouping!
        } catch let e {
            print(e.localizedDescription)
            grouping = Grouping(name: "shared")
        }
        
        //set the user defaults defaultGrouping Name
        //        UserDefaults.setDefaultGrouping
        
        return grouping
    }
    
    static func makeNewProjectOfFirstAvailableName(in grouping: inout Grouping) -> DeskProject {
        
        let projectsInGrouping = grouping.projects!
        let numberOfProjects = projectsInGrouping.count
        var storedNamesWithUntitled = [String]()
        var storedNumbersWhichAreTaken = [Int]()
        
        for project in projectsInGrouping {
            let projectName = project.getName()
            if (projectName.contains("Untitled")){
                storedNamesWithUntitled.append(projectName)
            }
        }
        
        for takenName in storedNamesWithUntitled {
            var numberInName = takenName.replacingOccurrences(of: "Untitled", with: "")
            var numOrNil =  Int(numberInName)
            if let num = numOrNil as! Int!{
                storedNumbersWhichAreTaken.append(num)
            }
        }
        
        storedNumbersWhichAreTaken.sort()
        
        var i: Int = 1
        for num in storedNumbersWhichAreTaken {
            if ( i == num){
                i+=1
            }
        }
        
        let projectWithProperName = DeskProject(name: "Untitled"+String(i))
        
        
        //takoing these out because the project should get saved to the grouping until the first stroke is written or other modification is made
     //   grouping.projects?.append(projectWithProperName)
     //   saveMetaData(of: grouping)
        
        return projectWithProperName
        
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
