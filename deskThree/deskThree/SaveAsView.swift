//
//  SaveAsView.swift
//  deskThree
//
//  Created by Cage Johnson on 3/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Zip

class SaveAsView: UIView {
    var workViewRef: WorkView!
    
    @IBOutlet var projectNameTextField: UITextField!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let projectName = projectNameTextField.text
        if(isAcceptableName(name: projectName!)){
            if(saveProject(name: projectName!)){
                print("Project saved successfully")
            } else {
                print("Project not saved")
            }
            closeButtonTapped(self)
        }else if(projectName == ""){
            workViewRef.raiseAlert(title: "", alert: "Enter project name.")
        }else if(projectName?.contains(" "))!{
            workViewRef.raiseAlert(title: "", alert: "Project name cannot contain spaces.")
        }
        
    }
    
    func isAcceptableName(name: String) -> Bool{
        return !(name.contains(" ") || name == "")
        
    }

    ///saves project and metadata to files. Returs true if success
    func saveProject(name: String) -> Bool{
        
        ///saves metadata of project to meta file. overwrite same name if present
        func saveMetaData(name: String){
            let project = DeskProject(name: name)
            project.modify()
            
            let filePath = PathLocator.getMetaFolder()+"/Projects.meta"
            
            var projects = PathLocator.loadMetaData()
            for i in 0..<projects.count{
                if projects[i].name == name{
                    //raise dialog asking user confirmation to overwrite
                    projects[i] = project
                    NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)
                    return
                }
            }
            projects.append(project)
            NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)
        }
        
        saveMetaData(name: name)
        
        //saves to documents/DeskThree/Projects/name.DESK
        let tempFolderPath = PathLocator.getTempFolder()
        let folderToZip = tempFolderPath+"/"+name
        
        //create the folder
        if(!FileManager.default.fileExists(atPath: folderToZip)){
            
            do {
                try FileManager.default.createDirectory(atPath: folderToZip, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        
        //save jot ui into the folder, folderToZip
        
        
        
        workViewRef.customDelegate.archiveJotView(folderToZip: folderToZip)
        
        
        
        //save the work area into the folder
        NSKeyedArchiver.archiveRootObject(workViewRef, toFile: folderToZip+"/WorkView.Desk")
        
        
        
        
        do{
            let destinationFolderURL = NSURL(string: PathLocator.getProjectFolder()) as! URL
            let zipFilePath = NSURL(string: PathLocator.getProjectFolder() + "/"+name)?.appendingPathExtension("DZIP")
            print(zipFilePath)
            if FileManager.default.fileExists(atPath: String(describing: zipFilePath)) {
                try FileManager.default.removeItem(at: zipFilePath!)
            }

            /*
            var thingsToZip = [URL]()
            for thing in try FileManager.default.contentsOfDirectory(atPath: folderToZip){
                thingsToZip.append( NSURL(string: folderToZip+"/"+thing) as! URL)
            }
            try Zip.zipFiles(paths: thingsToZip, zipFilePath: zipFilePath!, password: "password", progress: { (progress) -> () in
                print(progress)
            }) //Zip
            */
            Zip.addCustomFileExtension("DZIP")
            
            
            //try FileManager.default.removeItem(atPath: folderToZip)
        }
        catch{
            print("error when zipping file")
            return false
        }
        return true
        
    }
    
    
    

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()  
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    

}
