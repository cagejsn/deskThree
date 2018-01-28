//
//  MoveProjectPickerDataSource.swift
//  deskThree
//
//  Created by Cage Johnson on 1/21/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation


class MoveProjectAlertManager: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var fileSystemInteractor: FileSystemInteractor?
    weak var presentingVC: UIViewController?
    weak var projectToMove: DeskProject?
    
    typealias RunBlock = ()->()
    fileprivate var dismissalBlock: RunBlock?
    
    var selectedRow: Int = 0
    
    var groupingNames = [String]()
    
    
    func getGroupingNames() {
        let groupings = fileSystemInteractor!.getMetaData()
        for grouping in groupings {
            groupingNames.append(grouping.getName())
        }
    }
    
    func makeAlert() {
  
    getGroupingNames()
    self.preferredContentSize = CGSize(width: 250,height: 300)
        
    let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
    pickerView.delegate = self
    pickerView.dataSource = self
    self.view.addSubview(pickerView)
    
    let moveProjectAlert = UIAlertController(title: "Choose Destination", message: "", preferredStyle: .alert)
    pickerView.showsSelectionIndicator = true
    moveProjectAlert.setValue(self, forKey: "contentViewController")
    
    moveProjectAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: moveProjectHandler))
    moveProjectAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    pickerView.reloadAllComponents()
    presentingVC?.present(moveProjectAlert, animated: true)
    }
    
    //UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groupingNames.count
    }
    
    
    //UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return groupingNames[row]
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
   
    func moveProjectHandler( action: UIAlertAction) {
        let destGroupingName = groupingNames[selectedRow]
        let originGroupingName = projectToMove?.getOwnedByGroupingName()
        
        
        if(destGroupingName == originGroupingName){
            dismissalBlock?()
            return
        }
        
        let groupingName = projectToMove!.getOwnedByGroupingName()
        
        guard let grouping = try! MetaDataInteractor.getGrouping(withName: groupingName) as! Grouping! else {
            abort()
        }
        
        let change = MetaChange.MovedProject(destGroupingName: destGroupingName)
        fileSystemInteractor?.handleMeta(change, grouping: grouping, project: projectToMove!)
        dismissalBlock?()
        
        AnalyticsManager.track(.MoveProject)
    }
    
    func setDismissalBlock(block: @escaping RunBlock){
        dismissalBlock = block
    }
    
    func setProperties(_ fileSystemInteractor: FileSystemInteractor, _ presentingViewController: UIViewController, projectToMove: DeskProject){
        self.fileSystemInteractor = fileSystemInteractor
        self.presentingVC = presentingViewController
        self.projectToMove = projectToMove
    }
  
}
