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
    func didSelectProject(projectName: String)
    func dismissFileExplorer()
}


class FileExplorerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    weak var delegate: FileExplorerViewControllerDelegate!
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
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        label.text = metaDataFromDisk[indexPath.row].name
        cell.addSubview(label)
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metaDataFromDisk.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = metaDataFromDisk[indexPath.row].name
        delegate.didSelectProject(projectName: name!)
    }
}




