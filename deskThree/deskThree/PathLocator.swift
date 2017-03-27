//
//  PathLocator.swift
//  deskThree
//
//  Created by test on 3/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class PathLocator {
    
    ///Returns string to project folder location
    static func getProjectFolder() -> String{
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
        let projectsFolder = deskFolder+"/Projects"
        if (!fileManager.fileExists(atPath: projectsFolder)){
            print("Projects folder missing. Initializing...")
            
            do {
                try fileManager.createDirectory(atPath: projectsFolder, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return projectsFolder
    }
    
    ///Returns string to metadata folder location
    static func getMetaFolder() -> String{
        
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
