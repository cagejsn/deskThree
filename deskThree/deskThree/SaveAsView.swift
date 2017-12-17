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
    
    

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()  
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
