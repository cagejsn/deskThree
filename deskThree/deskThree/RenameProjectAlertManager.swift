//
//  RenameProjectAlertManager.swift
//  deskThree
//
//  Created by Cage Johnson on 1/27/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

class RenameProjectAlertManager {
    typealias renameHandler = (DeskProject,String)->()
    weak var fileSystemInteractor: FileSystemInteractor?
    weak var presentingVC: UIViewController?
    var nameFieldContents: String = ""
    var alertController = UIAlertController(title: "Rename Project", message: "enter a new name for the Project", preferredStyle: .alert)
    
    var projectToRename: DeskProject
    var renameHandler: renameHandler
    
    
    func showPrompt(){
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "New Name"
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: doRenameProject)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        presentingVC?.present(alertController, animated: true, completion: { _ in })
    }
    

    
    func doRenameProject(_ action: UIAlertAction) {
        nameFieldContents = alertController.textFields![0].text!
        self.renameHandler(projectToRename,nameFieldContents)
    }
    
    
    init(_ project: DeskProject, _ presentingViewController: UIViewController, renameHandler: @escaping renameHandler){
        self.presentingVC = presentingViewController
        self.renameHandler = renameHandler
        self.projectToRename = project
    }
}
