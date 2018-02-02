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
    
    static func getDeskArchive(at path: String) throws -> DeskArtifact {
        
        guard let archiveObject = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! DeskArtifact! else {
            throw DeskArchiveError.CantUnarchive
        }
        return archiveObject
    }
    
    static func put(_ archiveObject: DeskArtifact, at path: String){
        NSKeyedArchiver.archiveRootObject(archiveObject, toFile: path)
    }
    
}
