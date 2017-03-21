//
//  SaveAsView.swift
//  deskThree
//
//  Created by Cage Johnson on 3/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class SaveAsView: UIView {
    var workAreaRef: WorkArea!
    
    @IBOutlet var projectNameTextField: UITextField!
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let projectName = projectNameTextField.text
        if(projectName != ""){
        if(saveProject(name: projectName!)){print("yes")} else { print("no1")}
        }
        
        print("no2")
}


    ///saves project and metadata to files. Returs true if success
    func saveProject(name: String) -> Bool{
        
        ///saves metadata of project to meta file. overwrite same name if present
        func saveMetaData(name: String){
            let project = workAreaRef.project
            project?.modify()
            project?.rename(name: name)
            
            let filePath = PathLocator.getMetaFolder()+"/Projects.meta"
            
            var projects = PathLocator.loadMetaData()
            for i in 0..<projects.count{
                if projects[i].name == name{
                    //raise dialog asking user confirmation to overwrite
                    projects[i] = project!
                    NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)
                    return
                }
            }
            projects.append(project!)
            NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)
        }
        
        saveMetaData(name: name)
        
        //saves to documents/DeskThree/Projects/name.DESK
        let filePath = PathLocator.getProjectFolder()+"/"+name+".DESK"
        
        
        NSKeyedArchiver.archiveRootObject(workAreaRef.pages, toFile: filePath)
        
        return true
        
    }
    
    
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()  
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    

}
