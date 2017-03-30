//
//  FileExplorerViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 3/16/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Zip

protocol FileExplorerViewControllerDelegate {
    func didSelectProject(newWorkArea:WorkArea)
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
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metaDataFromDisk.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = metaDataFromDisk[indexPath.row].name
        let pathToUnzip = PathLocator.getProjectFolder() + "/" + name! + ".DZIP"
        
        let pathToTempFolder = PathLocator.getTempFolder()
        let pathToTempInstance = pathToTempFolder+"/"+name!
        if FileManager.default.fileExists(atPath: pathToTempInstance){
            do{
                try FileManager.default.removeItem(atPath: pathToTempInstance)
            }
            catch{}
        }
        //making the folder to temporarily hold the unzipped data
        do{
            try FileManager.default.createDirectory(atPath: pathToTempInstance, withIntermediateDirectories: true, attributes: nil)
        }
        catch{}
        
        Zip.addCustomFileExtension("DZIP")
        
        //unzipping file into just created directory
        do{
            try Zip.unzipFile(NSURL(string: pathToUnzip) as! URL, destination: NSURL(string: pathToTempInstance) as! URL, overwrite: true, password: "password", progress: { (progress) -> () in
                print(progress)
            })
            print("unzip successful")

            print("successfully created temp file of project")
        }
        catch let error as Error{
            print(error.localizedDescription)
            print("not unzipping file")
        }
        
        
        let unzippedWorkArea = NSKeyedUnarchiver.unarchiveObject(withFile: pathToTempInstance+"/WorkArea.Desk")
        if let workArea = unzippedWorkArea as? WorkArea {
            
            delegate.didSelectProject(newWorkArea: workArea)
        }
    }
}




