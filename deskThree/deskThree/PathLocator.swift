//
//  PathLocator.swift
//  deskThree
//
//  Created by test on 3/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class PathLocator {
    
    static func getTempFolder() -> String{
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        let deskFolder = documentsPath+"/DeskThree"
        if (!fileManager.fileExists(atPath: deskFolder)){
            print("D3 folder missing. Initializing...")
            
            do {
                try fileManager.createDirectory(atPath: deskFolder, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        let tempFolder = deskFolder+"/Temp"
        if (!fileManager.fileExists(atPath: tempFolder)){
            print("Projects folder missing. Initializing...")
            
            do {
                try fileManager.createDirectory(atPath: tempFolder, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return tempFolder
    }
    
    
    static func getArtifactsFolderFor(groupingName: String) -> String {
        let groupingsFolderPath = getGroupingsFolder()
        let pathForSpecificGrouping = groupingsFolderPath + "/" + groupingName
        let fileManager = FileManager.default
        if (!fileManager.fileExists(atPath: pathForSpecificGrouping)){
            print( groupingName + " folder missing. Initializing...")
            do {
                try fileManager.createDirectory(atPath: pathForSpecificGrouping, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return pathForSpecificGrouping
    }
    
    
    
    static func getGroupingsFolder() -> String{
        let deskFolderPath = getDeskFolderPath()
        let fileManager = FileManager.default
        let groupingsFolderPath = deskFolderPath+"/Groupings"
        if (!fileManager.fileExists(atPath: groupingsFolderPath)){
            print("Groupings folder missing. Initializing...")
            
            do {
                try fileManager.createDirectory(atPath: groupingsFolderPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return groupingsFolderPath
    }
    
    
    
    private static func getDeskFolderPath() -> String{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        let deskFolder = documentsPath+"/DeskThree"
        if (!fileManager.fileExists(atPath: deskFolder)){
            print("D3 folder missing. Initializing...")
            do {
                try fileManager.createDirectory(atPath: deskFolder, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return deskFolder
    }
    
    
    
    ///Returns string to project folder location
    static func getProjectFolder() -> String{
        let deskFolderPath = getDeskFolderPath()
        let fileManager = FileManager.default
        let projectsFolderPath = deskFolderPath+"/Projects"
        if (!fileManager.fileExists(atPath: projectsFolderPath)){
            print("Projects folder missing. Initializing...")
            
            do {
                try fileManager.createDirectory(atPath: projectsFolderPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return projectsFolderPath
    }
    
    ///Returns string to metadata folder location
    static func getMetaFolder() -> String {
        let deskFolder = getDeskFolderPath()
        let fileManager = FileManager.default
        let metaFolder = deskFolder+"/Meta"
        if (!fileManager.fileExists(atPath: metaFolder)){
            print("Meta data folder missing. Initializing...")
            
            do {
                try fileManager.createDirectory(atPath: metaFolder, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return metaFolder
    }
    
    

        
    
    ///returns metadata array if present. Otherwise, return empty array
    static func loadMetaData() -> [DeskProject]{
        let filePath = PathLocator.getMetaFolder() + "/Projects.meta"
        
        print(FileManager.default.fileExists(atPath: filePath))
        
        let file = NSKeyedUnarchiver.unarchiveObject(withFile: filePath)
        if let metaData = file as? [DeskProject] {
            return metaData
        }
        return []
    }
    
    
}
