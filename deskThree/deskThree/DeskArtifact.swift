//
//  DeskArchive.swift
//  deskThree
//
//  Created by Cage Johnson on 1/23/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

// DeskArchive is a abstract class for storage
// inside of a folder for a project, pdf, powerpoint, etc
// it should basically be a meta data token that describes
// what that folder thinks about the world around it
protocol DeskArtifact: NSCoding {
    
    
    var ownedByGrouping: String {
        get
    }
    
    
    var modified: Date { get }
    var createdTimeStamp: Date { get }
    var type: String { get }    
    func getUniqueProjectSerialNumber() -> Int
    func getName() -> String
    func rename(name: String)
}
