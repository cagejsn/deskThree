//
//  ProjectsDataSource.swift
//  deskThree
//
//  Created by Cage Johnson on 12/1/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol ProjectInteractionListener {
    func onProjectSelected(_ selectedGrouping: Grouping, _ selectedProject: DeskProject)
    func doRenameProject(_ project: DeskProject)
    func doMoveProject(_ project: DeskProject)
    func doDeleteProject(_ project: DeskProject)
    func doShareProject(_ projectCell: FileExplorerCollectionViewCell)
}


class ProjectsDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FECVEDelegate {
    
    
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    
    fileprivate let reuseIdentifier = "DeskCell"
    var projectInteractionListener: ProjectInteractionListener
    var selectedGrouping: Grouping!
    
    init(pIL: ProjectInteractionListener){
        self.projectInteractionListener = pIL
    }
    
    func notifyDataSetChanged(){
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let projects = selectedGrouping.projects!
        projectInteractionListener.onProjectSelected(selectedGrouping, projects[indexPath.row])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ( selectedGrouping == nil ) ? 0 : selectedGrouping.projects?.count
        return count!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,                                                      for: indexPath)
        
        if let fecve = cell as? FileExplorerCollectionViewCell {
            print(fecve.isUserInteractionEnabled)
            fecve.delegate = self
            fecve.readInData(project: selectedGrouping.projects![indexPath.row])
        }
        return cell
    }
    
    func displayProjectsIn(_ grouping: Grouping){
        selectedGrouping = grouping
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        return CGSize(width: 200   , height: 200)
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
        projectInteractionListener.doRenameProject(cell.project)
    }
    
    func onMoveTapped(_ cell: FileExplorerCollectionViewCell) {
        projectInteractionListener.doMoveProject(cell.project)
    }
    
    func onDeleteTapped(_ cell: FileExplorerCollectionViewCell) {
        projectInteractionListener.doDeleteProject(cell.project)
    }
    
    func onShareTapped(_ cell: FileExplorerCollectionViewCell) {
        projectInteractionListener.doShareProject(cell)
    }
    
    
}
