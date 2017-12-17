//
//  FileExplorerViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 3/16/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Zip

protocol FileExplorerViewControllerDelegate: NSObjectProtocol {
    func didSelectProject(grouping: Grouping, project: DeskProject)
    func newProjectRequestedIn(_ grouping: Grouping)
    func dismissFileExplorer()
    func openProjectWasRenamed(to newName: String)
}

class FileExplorerViewController: UIViewController, GroupingSelectedListener, ProjectInteractionListener {
    
  
    let tableViewCellHeight: CGFloat = 80
    
    static public let reuseIdentifier = "DeskCell"
    static public let reuseIdentifier2 = "NewCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet var fileExplorerHeaderView: FileExplorerHeaderView!
    
    @IBOutlet var tableView: GroupingTableView!
    @IBOutlet var collectionView: FileExplorerCollectionView!
    weak var delegate: FileExplorerViewControllerDelegate!
    @IBOutlet var collectionViewHeader: FileExplorerCollectionViewHeader!
    
    @IBOutlet var addGroupingButton: AddGroupingButton!
    
    fileprivate var groupingsDataSource: GroupingsDataSource!
    fileprivate var projectsDataSource: ProjectsDataSource!

    
    override func viewDidLoad() {
        groupingsDataSource = GroupingsDataSource(gSL: self)
        projectsDataSource = ProjectsDataSource(pIL: self)
        tableView.delegate = groupingsDataSource
        tableView.dataSource = groupingsDataSource
        collectionView.delegate = projectsDataSource
        collectionView.dataSource = projectsDataSource
        collectionView.register(UINib(nibName: "FileExplorerCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: FileExplorerViewController.reuseIdentifier)
        collectionView.register(UINib(nibName: "NewCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: FileExplorerViewController.reuseIdentifier2)
        
        collectionView.delaysContentTouches = false
        //function pointer is passed
        fileExplorerHeaderView.passCancel = { [weak self] in self?.cancelButtonTapped()}
        
//        addGroupingButton.contentMode = .scaleAspectFit
    }
    
    func cancelButtonTapped() {
        delegate.dismissFileExplorer()
    }
    
    @IBAction func onAddGroupingButtonTapped(_ sender: Any) {
        var newGroupingName: String = ""
        let alertController = UIAlertController(title: "New Grouping", message: "enter a name for the new Grouping", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "New Grouping Name"
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            newGroupingName = (alertController.textFields?[0].text)!
            var grouping = Grouping(name: newGroupingName)
            MetaDataInteractor.saveMetaData(of: grouping)
            //TODO: make the handleMeta of FileSystemInteractor less cumbersome, can't call it here because no project
            
            
            self.tableView.beginUpdates()
            
            self.groupingsDataSource.addAndSelectGroupingAtZeroIndex(grouping)
//        self.groupingsDataSource.notifyGroupingsChanged()
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            
//            self.tableView.reloadData()
            //select the new grouping
//            self.tableView.selectRow(at: , animated: true, scrollPosition: )
            self.projectsDataSource.selectedGrouping = grouping
            self.collectionViewHeader.setCurrentGroupingLabelText(text: grouping.getName())
            self.collectionView.notifyDataSetChanged()
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: { _ in })
    }
}

// MARK: Grouping Selected Listener
extension FileExplorerViewController {
    func onGroupingSelected(_ grouping: Grouping) {
        collectionViewHeader.setCurrentGroupingLabelText(text: grouping.getName())
        projectsDataSource.displayProjectsIn(grouping)
        collectionView.reloadData()
    }
}

// MARK: ProjectInteractionListener
extension FileExplorerViewController {
    func onProjectSelected(_ selectedGrouping: Grouping, _ selectedProject: DeskProject) {
        delegate.didSelectProject(grouping: selectedGrouping, project: selectedProject)
    }
    
    func doRenameProject(_ project: DeskProject) {
        var newProjectName: String = ""
        let alertController = UIAlertController(title: "Rename Project", message: "enter a new name for the Project", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "New Name"
        })
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            newProjectName = (alertController.textFields?[0].text)!
            var grouping = self.groupingsDataSource.selectedGrouping!
            var localProject = project
            let change = MetaChange.RenamedProject(newName: newProjectName)
            try! FileSystemInteractor.handleMeta(change, grouping: &grouping, project: &localProject)
            //sets the text of the Desk View Controle
            self.delegate.openProjectWasRenamed(to: newProjectName)
            //
            self.projectsDataSource.notifyDataSetChanged()
            self.collectionView.reloadData()
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: { _ in })
    }
    
    
    func doMoveProject(_ project: DeskProject) {
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
//        pickerView.delegate = self
//        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let editRadiusAlert = UIAlertController(title: "Choose distance", message: "", preferredStyle: UIAlertControllerStyle.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
        
        
        
        
    }
    
    func doDeleteProject(_ project: DeskProject) {
        let deleteAlert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this Desk Project? This cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //TODO: finish implementing the delete functionality
            
            
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func doShareProject(_ projectCell: FileExplorerCollectionViewCell) {
        
        
        var string = projectCell.project.getName()
        var url = ProjectFileInteractor.getURLofZippedProjectFolder(in: projectsDataSource.selectedGrouping, project: projectCell.project)
        let email = ShareSummary(title: string, url: url)
        
        var vc = UIActivityViewController(activityItems: [email], applicationActivities: nil )
        vc.popoverPresentationController?.sourceView = projectCell.projectOptionsMenu
        
       
        
        
        present(vc, animated: true, completion: nil)

    }
    
}

class ShareSummary: NSObject, UIActivityItemSource {
    var title: String
    var url: URL
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return URL(fileURLWithPath: "")
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return url
    }
    
    init(title: String , url: URL){
        self.title = title
        self.url = url
    }
    
    
}




//
extension FileExplorerViewController {
    func doMakeNewProjectInSelectedGrouping(_ grouping: Grouping){
        delegate.newProjectRequestedIn(grouping)
    }
    
}



