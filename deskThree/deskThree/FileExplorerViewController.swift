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
    var metaDataFromDisk: [NSObject]!
    
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate.dismissFileExplorer()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        cell.backgroundColor = UIColor.purple
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var workArea = WorkArea()
        delegate.didSelectProject(workArea: workArea)
    }
    

    
   
}




