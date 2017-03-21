//
//  FileExplorerViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 3/16/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol FileExplorerViewControllerDelegate {
    func didSelectProject(workArea:WorkArea)
    func dismissFileExplorer()
}


class FileExplorerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var delegate: FileExplorerViewControllerDelegate!
    var metaDataFromDisk: [DeskProject]!
    
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        metaDataFromDisk = PathLocator.loadMetaData()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate.dismissFileExplorer()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        label.text = metaDataFromDisk[indexPath.row].name
        cell.addSubview(label)
        cell.backgroundColor = UIColor.purple
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metaDataFromDisk.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var workArea = WorkArea()
        
        
        let path = PathLocator.getProjectFolder() + "/" + metaDataFromDisk[indexPath.row].name + ".DESK"
        let file = NSKeyedUnarchiver.unarchiveObject(withFile: path)
        print(file)
        
        
        delegate.didSelectProject(workArea: workArea)
    }

    
}




