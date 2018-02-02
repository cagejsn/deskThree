//
//  Grouping.swift
//  deskThree
//
//  Created by Cage Johnson on 11/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class Grouping: NSObject, NSCoding {
    
    var name: String?
    var artifacts: [DeskArtifact]
    var color: UIColor = UIColor.gray
    
    ///change name of grouping
    func rename(name: String){
        self.name = name
    }
    
    func getName()->String {
        return name!
    }
    
    func getArtifacts() -> [DeskArtifact]{
        return artifacts
    }
    
    func addArtifact(_ artifact: DeskArtifact){
        self.artifacts.append(artifact)
    }
    
    func removeArtifact(_ artifact: DeskArtifact){
        artifacts.removeObject(object: artifact as! DeskProject)
        
    }
    
    func setColor(color:UIColor){
        self.color = color
    }
    
    func getColor() -> UIColor {
        return self.color
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name)
        aCoder.encode(self.artifacts)
        aCoder.encode(self.color)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        artifacts = [DeskArtifact]()
        // Initialize the first page & set it as the current page
        let loadedName = aDecoder.decodeObject() as! String
        let loadedArtifacts = aDecoder.decodeObject() as? [DeskArtifact]
        let loadedColor = aDecoder.decodeObject() as? UIColor
        super.init()
        self.name = loadedName
        self.artifacts = loadedArtifacts!
    }
    
    init(name: String = DeskUserPrefs.nameOfDefaultGrouping()){
        self.name = name
        self.artifacts = [DeskArtifact]()
    }
}
