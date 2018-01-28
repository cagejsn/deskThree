//
//  MetaDataInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation



class MetaDataInteractor: NSObject {
    
    static func rename(grouping: Grouping, to newName: String) throws  {
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
        do {
            try fileManager.copyItem(atPath: currentPathOfGroupingMetaData, toPath: newPathForGroupingMetaData)
            
            try fileManager.removeItem(atPath: currentPathOfGroupingMetaData)
        } catch let e {
           throw e
        }
        
    }
   
    static func rename(project: DeskProject, to newName: String, in grouping: Grouping) throws {
        let projectName = project.getName()
        let groupingName = grouping.getName()
        var projects = grouping.getProjects()
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        
        var desiredProjectNameIsTaken: Bool = false
        for i in 0..<projects.count{
            if (projects[i].getName() == newName) {
                desiredProjectNameIsTaken = true
                throw DeskFileSystemError.ProjectNameTakenInGrouping(newName)
            }
        }
        
        for project_inMeta in projects {
            if (project_inMeta.getUniqueProjectSerialNumber() == project.getUniqueProjectSerialNumber()){
                project_inMeta.rename(name: newName)
                saveMetaData(of: grouping)
                return
            }
        }

    }
    
    static func remove(grouping: Grouping) throws {
        let fileManager = FileManager.default
        let groupingName = grouping.getName()
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        do{
            try fileManager.removeItem(atPath: filePath)
        } catch let e {
            throw e
        }
    }
    
    static func remove(project: DeskProject, from grouping: Grouping) {
        grouping.removeProject(project)
        saveMetaData(of: grouping)
    }
    
    static func save(project: DeskProject, intoGroupingWithName groupingName: String) throws {
        let fileManager = FileManager.default
        let filePath = PathLocator.getMetaFolder()+"/"+groupingName+".meta"
        
        let grouping: Grouping?
        if(!fileManager.fileExists(atPath: filePath)){
            //no Grouping with destination name
            PathLocator.getProjectsFolderFor(groupingName: groupingName)
            grouping = Grouping(name: groupingName)
        } else {
            grouping = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Grouping
        }
        if let grouping = grouping as! Grouping! {
            let incomingProjectName = project.getName()
            if(!isProjectNameTakenIn(grouping: grouping, name: incomingProjectName)){
            grouping.addProject(project)            
            project.setOwnedByGroupingName(newGroupingOwner: grouping.getName())
            saveMetaData(of: grouping)
            } else {
                throw DeskFileSystemError.ProjectNameTakenInGrouping(incomingProjectName)
            }
        }
    }
    
    static func isProjectNameTakenIn(grouping: Grouping, name: String) -> Bool {
        let projects = grouping.projects
        for i in 0..<projects.count{
            if (projects[i].getName() == name) {
                return true
            }
        }
        return false
    }
    
    static func save(project openProject: DeskProject, into grouping: Grouping) throws {
        let openProjectName = openProject.getName()
        var projects = grouping.getProjects()
        
        var projectNameIsTaken = true
        var attemptsToRename: Int = 0
        while(projectNameIsTaken){
            var i = 0
            while (i < projects.count){
                if (projects[i].getName() == openProject.getName()) {
                    attemptsToRename += 1
                    openProject.rename(name: openProjectName+"("+String(attemptsToRename)+")")
                    i = 0
                    continue
                }
                i += 1
            }
            projectNameIsTaken = false
        }
        
        grouping.addProject(openProject)

        openProject.setOwnedByGroupingName(newGroupingOwner: grouping.getName())
        
        do {
            try saveMetaData(of: grouping)
        } catch let e {
            throw e
        }
        
    }
    
    ///saves metadata of a grouping to meta file. overwrite same name if present
    static func saveMetaData(of grouping: Grouping) {
        let fileManager = FileManager.default
        let name = grouping.getName()
        let filePath = PathLocator.getMetaFolder()+"/"+name+".meta"
        NSKeyedArchiver.archiveRootObject(grouping, toFile: filePath)
    }
    
    static func getGrouping(withName groupingName:String) throws -> Grouping {
        let fileManager = FileManager.default
        let metaFolderPath = PathLocator.getMetaFolder()
        let proposedGroupingPath = metaFolderPath + "/" + groupingName + ".meta"
        if !fileManager.fileExists(atPath: proposedGroupingPath){
            throw DeskFileSystemError.NoGroupingMetaFileWithName(groupingName)
        }
        let data = NSKeyedUnarchiver.unarchiveObject(withFile: proposedGroupingPath)
        guard let grouping = data as! Grouping! else {
            throw DeskFileSystemError.NoGroupingMetaFileWithName(groupingName)
        }
        return grouping
    }
    
    static func getDefaultGrouping() -> Grouping{
        var defaultGrouping: String = DeskUserPrefs.nameOfDefaultGrouping()

        var grouping: Grouping
        do {
            grouping = try getGrouping(withName: defaultGrouping) as! Grouping!
        } catch let e {
            print(e.localizedDescription)
            grouping = Grouping(name: defaultGrouping)
        }
              
        return grouping
    }
    
    static func getSharedWithMeGrouping() -> Grouping{
        var sharedGrouping: String = "shared"
        
        var grouping: Grouping
        do {
            //grouping already exists
            grouping = try getGrouping(withName: sharedGrouping) as! Grouping!
        } catch let e {
            print(e.localizedDescription)
            grouping = Grouping(name: "shared")
        }
        
        //set the user defaults defaultGrouping Name
        //        UserDefaults.setDefaultGrouping
        
        return grouping
    }
    
    static func determineIfGroupingAlreadyExists(with name: String) ->Bool {
        let groupings = retrieveAllGroupingMetaData()
        for grouping in groupings {
            if(grouping.getName() == name){
                return true
            }
        }
        return false
    }
    
    static func makeNewProjectOfFirstAvailableName(in grouping: Grouping) -> DeskProject {
        
        let projectsInGrouping = grouping.projects
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
        
        let projectWithProperName = DeskProject(name: "Untitled"+String(i), ownedByGrouping: grouping.getName())
        
        //taking these out because the project should get saved to the grouping until the first stroke is written or other modification is made
     //   grouping.projects?.append(projectWithProperName)
     //   saveMetaData(of: grouping)
        
        return projectWithProperName
    }
    
    //TODO: on first install crash here, has to do with Project.meta
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
