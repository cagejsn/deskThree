//
//  GroupingsDataSource.swift
//  deskThree
//
//  Created by Cage Johnson on 12/1/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol GroupingSelectedListener {
    func onGroupingSelected(_ groupingName: String)
}

class GroupingsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let tableViewCellHeight: CGFloat = FileExplorerConstants.TABLE_VIEW_CELL_HEIGHT
    let tableViewCellWidth: CGFloat = FileExplorerConstants.TABLE_VIEW_CELL_WIDTH
    var groupingsToDisplay: [Grouping]!
    var selectedGrouping: Grouping?
    var groupingSelectedListener: GroupingSelectedListener
    var fileSystemInteractor: FileSystemInteractor!
    
    init(gSL: GroupingSelectedListener, fSI: FileSystemInteractor) {
        self.groupingSelectedListener = gSL
        self.fileSystemInteractor = fSI
        groupingsToDisplay = fileSystemInteractor.getMetaData().sorted(by: {return $0.0.getName() < $0.1.getName() })
    }
    
    func addAndSelectGroupingAtZeroIndex(_ grouping: Grouping){
        groupingsToDisplay.insert(grouping, at: 0)
        selectedGrouping = grouping
        groupingSelectedListener.onGroupingSelected(selectedGrouping!.getName())

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var groupingForCell = groupingsToDisplay[indexPath.row]
        let cell = GroupingTableViewCell(frame: CGRect(x:0,y:0,width: tableViewCellWidth ,height: tableViewCellHeight), text: groupingForCell.getName() , color: groupingForCell.getColor().cgColor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupingsToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGrouping = groupingsToDisplay[indexPath.row]
        groupingSelectedListener.onGroupingSelected(selectedGrouping!.getName())
    }
    
    
    func notifyGroupingsChanged(){
        groupingsToDisplay = fileSystemInteractor.getMetaData().sorted(by: {return $0.0.getName() < $0.1.getName() })
    }
    
}
