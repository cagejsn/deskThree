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
    var workAreaRef: WorkArea!
    
    @IBOutlet var projectNameTextField: UITextField!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let projectName = projectNameTextField.text
        if(projectName != ""){
            if(saveProject(name: projectName!)){
                print("Project saved successfully")
            } else {
                print("Project not saved")
            }
        closeButtonTapped(self)
        }else{
            workAreaRef.raiseAlert(title: "", alert: "Enter Name.")
        }
        
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
        //save the work area into the folder
        NSKeyedArchiver.archiveRootObject(workAreaRef, toFile: folderToZip+"/WorkArea.Desk")
        
        //save jot ui into the folder
        
        
        
        
        do{
            let destinationFolderURL = NSURL(string: PathLocator.getProjectFolder()) as! URL
            let zipFilePath = NSURL(string: PathLocator.getProjectFolder() + "/"+name)?.appendingPathExtension("DZIP")
            print(zipFilePath)
            if FileManager.default.fileExists(atPath: String(describing: zipFilePath)) {
                print("File exists, removing")
                try FileManager.default.removeItem(at: zipFilePath!)
                print("removed duplicate file")
            }
            print("about to attempt zipping files")
            var thingsToZip = [URL]()
            for thing in try FileManager.default.contentsOfDirectory(atPath: folderToZip){
                thingsToZip.append( NSURL(string: folderToZip+"/"+thing) as! URL)
            }
            try Zip.zipFiles(paths: thingsToZip, zipFilePath: zipFilePath!, password: "password", progress: { (progress) -> () in
                print(progress)
            }) //Zip
            print("zip successful")
            Zip.addCustomFileExtension("DZIP")
            
            
            try FileManager.default.removeItem(atPath: folderToZip)
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
