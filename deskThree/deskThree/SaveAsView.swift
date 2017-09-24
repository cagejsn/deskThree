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
            //saveProject(name: projectName!)
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
    
    //currently just renames current project
    static func renameProject(name: String, workViewRef: WorkView){
        
        //return if they want to rename the project to its current name
        if(name == workViewRef.getDeskProject().name){
            return
        }
        
        let newName = name
        let oldName = workViewRef.getDeskProject().name
        let temp = PathLocator.getTempFolder()
        
        var projects = PathLocator.loadMetaData()
        for i in  0..<projects.count {
            //in case we caught a file that we want to replace
            if projects[i].name == newName{
                projects.remove(at: i)
                break
            }
        }
        do{
            try FileManager.default.removeItem(atPath: temp+"/"+newName)
        }
        catch{
            print("file did not exist")
        }
        //in case we caught the file that we want to change the name of
        for i in 0..<projects.count {
            if projects[i].name == oldName{
                projects[i].name = newName
            }
        }
        
        do{
            try FileManager.default.moveItem(atPath: temp+"/"+oldName!, toPath: temp+"/"+newName)
        }
        catch{
            print("error, project dir not moved correctly")
        }
        NSKeyedArchiver.archiveRootObject(projects, toFile: PathLocator.getMetaFolder()+"/Projects.meta")
        workViewRef.getDeskProject().name = name
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()  
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
