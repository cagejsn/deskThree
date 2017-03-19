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
    
    
    ///saves metadata of project to meta file. overwrite same name if present
    func saveProject(name: String){
        let project = workAreaRef.project
        project?.modify()
        project?.rename(name: name)
        
        let filePath = PathLocator.getMetaFolder()+"/projects.meta"
        
        var projects = PathLocator.loadMetaData()
        for i in 0..<projects.count{
            if projects[i].name == name{
                //raise dialog asking user confirmation to overwrite
                projects[i] = project!
                NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)
            }
        }
        projects.append(project!)
        NSKeyedArchiver.archiveRootObject(projects, toFile: filePath)

    }
    
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()  
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    

}
