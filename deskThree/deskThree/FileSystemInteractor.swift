//
//  FileSystemInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Zip

enum PaperChange {
    case MovedBlock
    case AddedStroke
    case MovedImage
    case CreatedNewPage(atIndex: Int)
    case ClearedPage
}

enum MetaChange {
    case DeletedGrouping
    case RenamedGrouping(newName: String)
    case CreatedGrouping
    case RenamedProject(newName: String, isOpen: Bool)
    case MovedProject(destGroupingName: String)
    case DeletedProject
    case CreatedProject
}

enum DeskFileSystemError: Error {
    case FileNameIsTakeDuringRenameOperation(String)
    case ProjectNameTakenInGrouping(String)
    case NoGroupingMetaFileWithName(String)
    case NeededDirectoryIsMissing
    case MissingFolderWithProjectContents
    case ProjectDirectoryAlreadyExistsInTemp
    case CouldNotGetNamesOfFoldersInTemp
    case DidntFindPaperAtPath
}


class FileSystemInteractor: NSObject {
    
    var metaDataInteractor: MetaDataInteractor?
    var projectFileInteractor: ProjectFileInteractor?
    var viewController: UIViewController!
    
    func showMessageFor(_ error: Error){
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) {
            (action: UIAlertAction) in print("Youve pressed OK Button")
        }
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorMessageWithText(_ text: String){
        let renameAlert = UIAlertController(title: "Error", message: text, preferredStyle: UIAlertControllerStyle.alert)
        renameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
        }))
        viewController.present(renameAlert, animated: true, completion: nil)
    }
    
    func showCantRenameError(){
        //TODO: what if someone changes the name of a project before it is ever written to disk
        
        let renameAlert = UIAlertController(title: "Project Name Taken", message: "the rename operation failed.", preferredStyle: UIAlertControllerStyle.alert)
            
            renameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
        viewController.present(renameAlert, animated: true, completion: nil)
       
    }
    
    //should only be available when open
    func handlePaper(change: PaperChange, grouping: Grouping, project: DeskProject, page: Paper){
        switch (change){
            
        case .MovedBlock:
            archivePageObjectsIntoTempFolder(for: page, project: project)
            break
            
        case .AddedStroke:
            PaperInteractor.save(paper: page, in: project, in: grouping)
            break
            
        case .MovedImage:
            archivePageObjectsIntoTempFolder(for: page, project: project)
            break
            
        case .CreatedNewPage(let atIndex):
            //TODO add logic for inserting a page in the middle of a document
            getPageDirectoryInTempFor(pageNo: atIndex, in: project)
            break
            
        case .ClearedPage:
            PaperInteractor.save(paper: page, in: project, in: grouping)
            break
            
        default:
            //not found
            //mix of overloaded parameters and cases
            abort()
            break
        }
    }
    
    //can also be reached from the fileExplorer
    func handleMeta(_ change: MetaChange, grouping: Grouping, project: DeskProject) -> Bool{
        
        switch (change){
            case .MovedProject(let destinationGroupingName):
                
                let sourceURL = try! ProjectFileInteractor.getURLofFolderForArtifactInGroupingsFile(in: grouping, artifact: project)
                let destURL = URL(fileURLWithPath: PathLocator.getArtifactsFolderFor(groupingName: destinationGroupingName))
                
                do {
                    try FileManager.default.moveItem(at: sourceURL, to: destURL.appendingPathComponent(sourceURL.lastPathComponent))
                    
                    MetaDataInteractor.remove(project: project, from: grouping)
                    try MetaDataInteractor.save(project: project, intoGroupingWithName: destinationGroupingName)
                    
                } catch DeskFileSystemError.MissingFolderWithProjectContents {
                    showErrorMessageWithText("Missing Folder with Project Contents")
                } catch DeskFileSystemError.NoGroupingMetaFileWithName {
                    
                } catch DeskFileSystemError.ProjectNameTakenInGrouping(let incomingProjectName) {
                    showErrorMessageWithText("There already is a project named " + incomingProjectName + "in " + destinationGroupingName)
                    try? FileManager.default.moveItem(at: destURL.appendingPathComponent(sourceURL.lastPathComponent), to: sourceURL )
                    try? MetaDataInteractor.save(project: project, into: grouping)
                } catch let e {
                    showMessageFor(e)
                }
                break
            
            
            case .DeletedProject:
                
                //TODO: remove the .zip file from the Grouping's folder
                do {
                    try MetaDataInteractor.remove(project: project, from: grouping)
                    let sourceURL = try ProjectFileInteractor.getURLofFolderForArtifactInGroupingsFile(in: grouping, artifact: project)
                    let fileManager = FileManager.default
                    try fileManager.removeItem(at: sourceURL)
                
                } catch let e {
                    showMessageFor(e)
                }
                break
            
            case .CreatedProject:
                //TODO: hmm should we add a .zip into
                do {
                    try MetaDataInteractor.save(project: project, into: grouping)
                } catch let e {
                    showMessageFor(e)
                }
                break
            
            case .RenamedProject(let newName, let isOpen):
                let oldName = project.getName()
                
                do{
                    //find out if there is a Project folder in the grouping
                    let projectFolderExistsinGrouping = ProjectFileInteractor.isFolderIn(grouping: grouping , with: oldName)
                    
                    
                    //always going to need to rename MetaData
                    try MetaDataInteractor.rename(project: project, to: newName, in: grouping)
                    
                    if (isOpen) {
                        // let's find out if there is a project with a name that we want in Temp
                        // since this is a freak state, we should handle it by moving that other
                        let isDesiredNameTakenInTemp: Bool = ProjectFileInteractor.isFolderInTemp(project: newName)
                        if (isDesiredNameTakenInTemp) { removeFolderFromTemp(withName: newName) }
                        //here we will change the name of the directory in Temp
                        try ProjectFileInteractor.renameProjectDirectoryInTemp(oldName: oldName, newName: newName)
                        
                        if(projectFolderExistsinGrouping){
                        try ProjectFileInteractor.renameProjectFolderInGroupingFolder(oldProjectName: oldName,newProjectName: newName,in: grouping.getName())
                        }
                        
                        let artifactPath = PathLocator.getTempFolder() + "/" + project.getName() + "/" + Constants.DESK_ARTIFACT_PATH_COMPONENT
                        ArchiveInteractor.put(project, at: artifactPath)
                        
                        //TODO: rename when the project hasn't been put in the Grouping Storage folder
                    } else {
                        //project isn't open, find it in grouping folder, and change the name of the folder
                        try ProjectFileInteractor.renameProjectFolderInGroupingFolder(oldProjectName: oldName, newProjectName: newName, in: grouping.getName())
                    }
                    
                    return true
                } catch DeskFileSystemError.ProjectNameTakenInGrouping(let desiredName) {
                    //normal error, life is fine, we also never tried renaming something in the file system
                    showCantRenameError()
                    return false
                } catch let e {
                    // rename operation failed after the MetaData was changed, revert it
                    try! MetaDataInteractor.rename(project: project, to: oldName, in: grouping)
                    showMessageFor(e)
                }
                break
            
            
            case .DeletedGrouping:
                do {
                    try MetaDataInteractor.remove(grouping: grouping)
                } catch let e {
                    showMessageFor(e)
                }
                break
            
            
            case .RenamedGrouping(let newName):
                do {
                    try MetaDataInteractor.rename(grouping: grouping, to: newName)
                } catch let e {
                    showMessageFor(e)
                }
                break
            
            
            case .CreatedGrouping:
                do {
                    try MetaDataInteractor.saveMetaData(of: grouping)
                } catch let e {
                    showMessageFor(e)
            }
                break
            
            default:
                //not found
                //mix of overloaded parameters and cases
                abort()
                break
        }
        return true
    } //end of function
    /*
    static func findAndLoad(project: String,in grouping: String, to page: Int, ){
        
        
    }
*/
    
    func removeFolderFromTemp(withName name: String) {
        let tempPath = PathLocator.getMetaFolder()
        let urlWithFolder = URL(fileURLWithPath: tempPath + "/" + name, isDirectory: true)
        do {
        try FileManager.default.removeItem(at: urlWithFolder)
        } catch let e {
            showMessageFor(e)
        }
    }
    
    
    func afterLoading(pageNo: Int, inProject: String, fromGrouping: String, run loadingCompletionBlock: (inout Grouping,inout DeskProject,inout Paper, inout [Paper]) -> ()){
        
        let fileManager = FileManager.default
        
        var grouping = try! MetaDataInteractor.getGrouping(withName: fromGrouping)
        let groupingProjects = grouping.artifacts
        
        var seekForProject: DeskProject?
        for project in groupingProjects {
            if project.getName() == inProject{
            seekForProject = project as? DeskProject
            break
            }
        }
        
        //go get the zipped file of the same name as the DeskProject which will be in this Grouping's folder, load that thing in to the Temp Folder
        do {
        try getProjectFolderFromGroupingAndCopyToTemp(project: seekForProject!, grouping: grouping)
        } catch let e {
            print( e.localizedDescription )
        }
        
        let projectPagesDirInTemp = getProjectDirectoryInTemp(project: seekForProject!)
        
        
        
        let pagesAsStrings = try! fileManager.contentsOfDirectory(atPath: projectPagesDirInTemp)
        
        var pages = [Paper]()
        
        var i: Int = 1
        for page in pagesAsStrings {
            
            let pathToDesiredPageFolder = getPageDirectoryInTempFor(pageNo: i, in: seekForProject!)
            
            //TODO: bug when there is no page.desk
            let pathToArchivedPaperObject = pathToDesiredPageFolder + "/page.desk"
            var data = NSKeyedUnarchiver.unarchiveObject(withFile: pathToArchivedPaperObject)
            
            if var paper = data as! Paper! {
                pages.append(paper)
            }
            i += 1
        }
        loadingCompletionBlock(&grouping, &seekForProject!, &pages[pageNo - 1], &pages)

    }
    
    
    func getMetaData() -> [Grouping] {
        
        let groupings = MetaDataInteractor.retrieveAllGroupingMetaData()
        return groupings
    }
    
    func getProjectDirectoryInTemp(project: DeskProject) -> String {
        
        let path = try! ProjectFileInteractor.makeProjectDirectoryInTemp(withName: project.getName())
        return path
    }
    
    func getPageDirectoryInTempFor(pageNo: Int, in project: DeskProject)-> String {
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
    
    func archivePageObjectsIntoTempFolder(for page: Paper, project: DeskProject){
        let pageDirectory = getPageDirectoryInTempFor(pageNo: page.getPageNumber(), in: project)
        NSKeyedArchiver.archiveRootObject(page, toFile: pageDirectory + "/page.desk")
    }
    
    func archiveJotView(for page: Paper, project: DeskProject){
        let pageDirectory = getPageDirectoryInTempFor(pageNo: page.getPageNumber(), in: project)
        JotFilesInteractor.saveDrawing(for: page, in: project)
       // page.saveDrawing(at: pageDirectory)
        
    }
    
    func ensureDirectoriesExist(_ projectFolderPathInTemp: String, _ groupingFolder: String ) throws{
        let fileManager = FileManager.default
        var isDirectoryBool: ObjCBool = ObjCBool(false)
        
        if(!fileManager.fileExists(atPath: projectFolderPathInTemp, isDirectory: &isDirectoryBool)) {
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }
        if(!fileManager.fileExists(atPath: groupingFolder, isDirectory: &isDirectoryBool)){
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }
        if (!isDirectoryBool.boolValue){
            throw DeskFileSystemError.NeededDirectoryIsMissing
        }
    }
    
    func moveArtifactFromTempFolderAndPlaceInGroupingFolder(artifact: DeskArtifact, grouping: Grouping) throws {
        let tempFolderPath = PathLocator.getTempFolder()
        let fileManager = FileManager.default
        let projectFolderPathInTemp = tempFolderPath + "/" + artifact.getName()
        let groupingFolder = PathLocator.getArtifactsFolderFor(groupingName: grouping.getName())

        do {
            try ensureDirectoriesExist(projectFolderPathInTemp, groupingFolder)
        } catch let e {
            showMessageFor(e)
        }
        // now we know that there are two DIRECTORIES, one is the project Folder in TEMP
        // which we will zip and the other is the Grouping's Folder where the zipped projects live
        
        let destinationPath =  URL(fileURLWithPath: groupingFolder).appendingPathComponent(artifact.getName())
        let sourcePath = URL(fileURLWithPath: projectFolderPathInTemp)
     
        do {
            try fileManager.moveItem(at: sourcePath, to: destinationPath)
        } catch let e {
            do {
                try fileManager.replaceItemAt(destinationPath, withItemAt: sourcePath)
            } catch let e {
                showMessageFor(e)
            }
        }
       
    }
    
    func getProjectFolderFromGroupingAndCopyToTemp(project: DeskProject, grouping: Grouping) throws {
        
        let tempFolderPath = PathLocator.getTempFolder()
        let fileManager = FileManager.default
        
        let groupingFolder = PathLocator.getArtifactsFolderFor(groupingName: grouping.getName())
        let projectFolderPath = groupingFolder + "/" + project.getName()
        
        do{
            try ensureDirectoriesExist(tempFolderPath, groupingFolder)
        } catch let e {
            showMessageFor(e)
        }
        
        if (!fileManager.fileExists(atPath:projectFolderPath)){
            throw DeskFileSystemError.MissingFolderWithProjectContents
        }
        
        let sourceURL = URL(fileURLWithPath: projectFolderPath)
        let folderSpecificPathComponent = sourceURL.lastPathComponent
        let destinationURL = URL(fileURLWithPath: tempFolderPath).appendingPathComponent(folderSpecificPathComponent)
 
        //all good, lets move into a directory
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        } catch let e {
            showMessageFor(e)
        }
    }
    
    
    ///this function is only concerned with the Meta Data
    func handleFirstProjectEdit(grouping: Grouping, project: DeskProject, page: Paper){
        let change = MetaChange.CreatedProject
        //1. add the project to the grouping
        do {
            try handleMeta(change, grouping: grouping, project: project)
        } catch DeskFileSystemError.FileNameIsTakeDuringRenameOperation(let takenName) {
            showErrorMessageWithText("name is taken" + takenName)
        } catch let e {
            showMessageFor(e)
        }
        
        //2. write the grouping's meta file to the Meta Folder
        
        //3. 
        
        //TODO: in this function we are going to make the temp folder and also the grouping if it hasn't been saved yet
        
    }
    
    /// only is concerned with Temp folder
    func handleFirstPageEdit(project: DeskProject, page: Paper){
        
        getPageDirectoryInTempFor(pageNo: page.getPageNumber(), in: project)
        archivePageObjectsIntoTempFolder(for: page, project: project)
        
    }
    
    func detectGroupingsWithMissingProjects() -> [Grouping]{
        var groupingsWithMissingProjects = [Grouping]()
        let groupings = getMetaData()
        for grouping in groupings {
            for project in grouping.artifacts {
                do {
                    try ProjectFileInteractor.getURLofFolderForArtifactInGroupingsFile(in: grouping, artifact: project)
                } catch DeskFileSystemError.MissingFolderWithProjectContents {
                    //Project Folder is missing
                    groupingsWithMissingProjects.append(grouping)
                } catch let e {
                    print(e.localizedDescription)
                }
            }
        }
        return groupingsWithMissingProjects
    }
    
    func moveToFillSpotInGrouping(_ missingGroupingProjectPairs: [(Grouping, DeskProject)],lookupValue:(groupingNameForPage: String, projectNameFromTemp: String)) -> Bool {
        
        for pair in missingGroupingProjectPairs {
            if (pair.0.getName() == lookupValue.groupingNameForPage) && (pair.1.getName() == lookupValue.projectNameFromTemp) {
                //found match
                //move the project folder there
                do {
                    try moveArtifactFromTempFolderAndPlaceInGroupingFolder(artifact: pair.1, grouping: pair.0)
                } catch let e {
                    showMessageFor(e)
                    return false
                }
                removeArtifactFromTemp(artifact: pair.1)
                return true
            }
        }
        return false
    }
    
    func moveProjectFolderToGroupingFolderIfMatchFound(in grouping: Grouping, homeless artifact: DeskArtifact) -> Bool{
        for project in grouping.artifacts {
            if(project.getUniqueProjectSerialNumber() == artifact.getUniqueProjectSerialNumber()){
                //found it
                do {
                    try moveArtifactFromTempFolderAndPlaceInGroupingFolder(artifact: project, grouping: grouping)
                } catch let e {
                    showMessageFor(e)
                    return false
                }
//                removeArtifactFromTemp(artifact: project)
                return true
            }
        }
        return false
    }
    
    // upon re-open, Desk takes all the temp folders and trys to find where they belong
    func saveLostState() throws {
        let fileManager = FileManager.default
        let tempFolderPath = PathLocator.getTempFolder()
        let groupingsWithMissingProjects = detectGroupingsWithMissingProjects()
        
        guard let namesOfFoldersInTemp = try? fileManager.contentsOfDirectory(atPath: tempFolderPath) else {
            throw DeskFileSystemError.CouldNotGetNamesOfFoldersInTemp
        }
        
        for folderName in namesOfFoldersInTemp {
            
            //get an desk.archive object and read it
            let pathToArchiveObject = tempFolderPath + "/" + folderName + "/" + Constants.DESK_ARTIFACT_PATH_COMPONENT
            guard let archiveObject = try? ArchiveInteractor.getDeskArchive(at: pathToArchiveObject) else {
                continue
            }
            
            for grouping in groupingsWithMissingProjects {
                if(moveProjectFolderToGroupingFolderIfMatchFound(in: grouping, homeless: archiveObject)){
                    continue
                }
            }
        }
    }
    
    func removeArtifactFromTemp(artifact: DeskArtifact){
        let tempFolderPath = PathLocator.getTempFolder()
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: tempFolderPath + "/" + artifact.getName())
        } catch let e {
            showMessageFor(e)
        }
    }
    
    init( _ viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }
}
