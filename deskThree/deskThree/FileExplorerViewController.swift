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
    func dismissFileExplorer()
}


class FileExplorerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let tableViewCellHeight: CGFloat = 80
    
    fileprivate let reuseIdentifier = "DeskCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBOutlet var fileExplorerHeaderView: FileExplorerHeaderView!
    @IBOutlet var userView: UserView!
    @IBOutlet var groupingsLabel: GroupingsLabel!
    @IBOutlet var selectGroupSegmentedControl: SelectGroupingSegmentedControl!
    @IBOutlet var cellSizeSlider: UISlider!
    @IBOutlet var tableView: GroupingTableView!
    @IBOutlet var collectionView: FileExplorerCollectionView!
    weak var delegate: FileExplorerViewControllerDelegate!
    var groupings: [Grouping]!
    
    var selectedGrouping: Grouping! = nil
    
    fileprivate var itemsPerRow: CGFloat = 4

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        groupings = FileSystemInteractor.getMetaData()
        
        collectionView.register(UINib(nibName: "FileExplorerCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: reuseIdentifier)
        
        //function pointer is passed
       // selectGroupSegmentedControl.segmentDidChange = { [weak self] in self?.segmentsWantsGroupingChange()}
        fileExplorerHeaderView.passCancel = { [weak self] in self?.cancelButtonTapped()}
    }
    
    //handle the change of the grouping
    func segmentsWantsGroupingChange(){
        let num = selectGroupSegmentedControl.selectedSegmentIndex
        groupingsLabel.updateText(for: num)
        
    }
    
    func cancelButtonTapped() {
        delegate.dismissFileExplorer()
    }
    
    
    @IBAction func cellSizeSliderValueChanged(_ sender: UISlider) {
        var oldItemsPerRow = itemsPerRow
        
        itemsPerRow = { () -> CGFloat in
                switch CGFloat(sender.value) {
                    
                case 0..<0.25:
                    return 7
                case 0.25..<0.5:
                    return 6
                case 0.5..<0.75:
                    return 5
                case 0.75..<1:
                    return 4
                default:
                    return 3
                }
        }()
        
        if(oldItemsPerRow != itemsPerRow){
            collectionView.invalidateIntrinsicContentSize()
            collectionView.reloadData()
        }
    }
}

// MARK: Table View Methods
extension FileExplorerViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var groupingForCell = groupings[indexPath.row]
        let cell = GroupingTableViewCell(frame: CGRect(x:0,y:0,width:200,height:tableViewCellHeight), text: groupingForCell.getName() , color: groupingForCell.getColor().cgColor)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupings.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGrouping = groupings[indexPath.row]
        collectionView.reloadData()
    }
}

// MARK: Collection View Methods
extension FileExplorerViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let projects = selectedGrouping.projects!
        delegate.didSelectProject(grouping: selectedGrouping, project: projects[indexPath.row])
        
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
            fecve.readInData(projectName: selectedGrouping.projects![indexPath.row].getName())
        }
        return cell
    }
}

extension FileExplorerViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
}


