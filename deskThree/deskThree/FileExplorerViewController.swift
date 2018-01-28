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
    func getChangeOpenProjectNameHandler() -> (String) -> (Bool)
    func getOpenProjectSerialNumber() -> Int
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
    
    fileprivate var openProjectSerialNumber: Int {
        get {
           return delegate.getOpenProjectSerialNumber()
        }
    }

    var fileSystemInteractor: FileSystemInteractor!
    
    override func viewDidLoad() {
        fileSystemInteractor = FileSystemInteractor(self)

        groupingsDataSource = GroupingsDataSource(gSL: self, fSI: fileSystemInteractor)
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
            let isGroupingNameTaken = MetaDataInteractor.determineIfGroupingAlreadyExists(with:newGroupingName)
            if(newGroupingName == "" || isGroupingNameTaken) {self.fileSystemInteractor.showErrorMessageWithText("Make a different name for the Grouping"); return}
            var grouping = Grouping(name: newGroupingName)
            do {
                try MetaDataInteractor.saveMetaData(of: grouping)
            } catch let e {
                let alertController = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
            }
            //TODO: make the handleMeta of FileSystemInteractor less cumbersome, can't call it here because no project
            
            self.tableView.beginUpdates()
            
            self.groupingsDataSource.addAndSelectGroupingAtZeroIndex(grouping)

            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            
        })
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: { _ in })
    }
}

// MARK: Grouping Selected Listener
extension FileExplorerViewController {
    func onGroupingSelected(_ groupingName: String) {
        collectionViewHeader.setCurrentGroupingLabelText(text: groupingName)
        projectsDataSource.displayProjectsIn(groupingName)
        collectionView.reloadData()
    }
}

// MARK: ProjectInteractionListener
extension FileExplorerViewController {
    func onProjectSelected(_ selectedGrouping: Grouping, _ selectedProject: DeskProject) {
        delegate.didSelectProject(grouping: selectedGrouping, project: selectedProject)
        AnalyticsManager.track(.ProjectSelected)
    }
    
    func showRenamePrompt(_ project: DeskProject) {
        let renameProjectAlertManager = RenameProjectAlertManager(project, self, renameHandler: doRenameProject)
        renameProjectAlertManager.showPrompt()
    }
    
    func getSelectedGrouping() -> Grouping? {
        return groupingsDataSource.selectedGrouping
    }
    
    func doRenameProject(project: DeskProject, newName: String ){
        let serialNumberOfRenamingProject = project.getUniqueProjectSerialNumber()

        var handleRenameOpenProject: ((String)->(Bool))?
        let isOpen = serialNumberOfRenamingProject == self.openProjectSerialNumber
        if(isOpen){
            handleRenameOpenProject = self.delegate.getChangeOpenProjectNameHandler()
            if(handleRenameOpenProject!(newName)){
                onRenameProjectSuccess()
            }
        } else {
            let change = MetaChange.RenamedProject(newName: newName, isOpen: isOpen)
            if(fileSystemInteractor.handleMeta(change, grouping: getSelectedGrouping()!, project: project)){
                onRenameProjectSuccess()
            }
        }
    }
    
    func onRenameProjectSuccess(){
        self.projectsDataSource.notifyDataSetChanged()
        //reloading takes care of displaying the new name in the collection view
        self.collectionView.reloadData()
        AnalyticsManager.track(.RenameProjectFEVC)
    }
    
    
   
    
    func doMoveProject(_ project: DeskProject) {
        if(openProjectSerialNumber == project.getUniqueProjectSerialNumber()){
            showFailureMessageWith(text: "Can't move a project while open.")
        }
        let moveProjectAlertManager = MoveProjectAlertManager()
        moveProjectAlertManager.setProperties(fileSystemInteractor, self, projectToMove: project)
        moveProjectAlertManager.setDismissalBlock(block:{self.projectsDataSource.notifyDataSetChanged();self.collectionView.reloadData()})
        moveProjectAlertManager.makeAlert()
    }
    
    func doDeleteProject(_ project: DeskProject) {
        let deleteAlert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete this Desk Project? This cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //TODO: finish implementing the delete functionality
            
            AnalyticsManager.track(.DeleteProject)
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func doShareProject(_ projectCell: FileExplorerCollectionViewCell) {
        
        
        var string = projectCell.project.getName()
        guard var url = try? ProjectFileInteractor.getURLofFolderForProjectInGroupingsFile(in: projectsDataSource.selectedGrouping, project: projectCell.project) else {

            fileSystemInteractor.showMessageFor(DeskFileSystemError.MissingFolderWithProjectContents)
            return
        }
        let email = ShareSummary(title: string, url: url)
        
        var vc = UIActivityViewController(activityItems: [email], applicationActivities: nil )
        vc.popoverPresentationController?.sourceView = projectCell.projectOptionsMenu
        
       
        
        AnalyticsManager.track(.ShareProject)
        present(vc, animated: true, completion: nil)

    }
    
    func showFailureMessageWith(text: String ){
        let failureAlert = UIAlertController(title: "Failure", message: text, preferredStyle: UIAlertControllerStyle.alert)
        
        failureAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            //TODO: finish implementing the delete functionality
            
            
        }))
        present(failureAlert, animated: true, completion: nil)
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
        AnalyticsManager.track(.NewProjectFEVC)
    }
    
}



