//
//  ArchiveInteractor.swift
//  deskThree
//
//  Created by Cage Johnson on 1/23/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

enum DeskArchiveError: Error {
    case CantUnarchive
}

class ArchiveInteractor: NSObject {
    
    static func getDeskArchive(at path: String) throws -> DeskArchive {
        
        guard let archiveObject = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! DeskArchive! else {
            throw DeskArchiveError.CantUnarchive
        }
        return archiveObject
    }
    
    static func put(_ archiveObject: DeskArchive, at path: String){
        NSKeyedArchiver.archiveRootObject(archiveObject, toFile: path)
    }
    
}
