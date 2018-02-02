//
//  ProjectsDataSource.swift
//  deskThree
//
//  Created by Cage Johnson on 12/1/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol ProjectInteractionListener {
    func onArtifactSelected(_ selectedGrouping: Grouping, _ selectedArtifact: DeskArtifact)
    func showRenamePrompt(_ artifact: DeskArtifact)
    func doMoveProject(_ artifact: DeskArtifact)
    func doDeleteProject(_ artifact: DeskArtifact)
    func doShareArtifact(_ artifactCell: FileExplorerCollectionViewCell)
    func doMakeNewProjectInSelectedGrouping(_ grouping: Grouping)
}

class ProjectsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FECVEDelegate {
    
    fileprivate let sectionInsets = FileExplorerConstants.FILE_EXPLORER_EDGE_INSETS
    var projectInteractionListener: ProjectInteractionListener
    var selectedGrouping: Grouping!
    
    init(pIL: ProjectInteractionListener){
        self.projectInteractionListener = pIL
    }
    
    func notifyDataSetChanged(){
        selectedGrouping = try! MetaDataInteractor.getGrouping(withName: selectedGrouping.getName())
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        var projectsCount = selectedGrouping?.artifacts.count
        let isNew = projectsCount == nil ? true :
            { () -> Bool in
            if row  == selectedGrouping!.artifacts.count {
                //new project
                return true
            }
            return false
            }()
        
        if isNew {
        projectInteractionListener.doMakeNewProjectInSelectedGrouping(selectedGrouping)
            return
        }
        
        let projects = selectedGrouping.artifacts
        projectInteractionListener.onArtifactSelected(selectedGrouping, projects[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ( selectedGrouping == nil ) ? 0 : selectedGrouping.artifacts.count + 1
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var newProjectSpot: Int = 0
        if selectedGrouping != nil { newProjectSpot = (selectedGrouping?.artifacts.count)! }
        
        if(indexPath.row == newProjectSpot){
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileExplorerViewController.reuseIdentifier2, for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileExplorerViewController.reuseIdentifier,                                                      for: indexPath)
        
        if let fecve = cell as? FileExplorerCollectionViewCell {
            print(fecve.isUserInteractionEnabled)
            fecve.delegate = self
            fecve.readInData(artifact: selectedGrouping.artifacts[indexPath.row])
        }
        return cell
    }
    
    func displayProjectsIn(_ groupingName: String){
        do {
            selectedGrouping = try MetaDataInteractor.getGrouping(withName: groupingName)
        } catch DeskFileSystemError.NoGroupingMetaFileWithName(let name){
            abort()
        } catch let e {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        return CGSize(width: FileExplorerConstants.FILE_EXPLORER_VIEW_CELL_WIDTH , height: FileExplorerConstants.FILE_EXPLORER_VIEW_CELL_HEIGHT)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    //MARK: FECVCDelegate Method Stubs
    func renameTappedForCell(_ cell: FileExplorerCollectionViewCell) {
        projectInteractionListener.showRenamePrompt(cell.artifact)
    }
    
    func onMoveTapped(_ cell: FileExplorerCollectionViewCell) {
        projectInteractionListener.doMoveProject(cell.artifact)
    }
    
    func onDeleteTapped(_ cell: FileExplorerCollectionViewCell) {
        projectInteractionListener.doDeleteProject(cell.artifact)
    }
    
    func onShareTapped(_ cell: FileExplorerCollectionViewCell) {
        projectInteractionListener.doShareArtifact(cell)
    }
}
