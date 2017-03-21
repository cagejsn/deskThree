//
//  DeskProject.swift
//  deskThree
//
//  Created by test on 3/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class DeskProject: NSObject, NSCoding {
    
    var name: String!
    var modified: Date!
    

    func rename(name: String){
        self.name = name
    }
    
    func modify(){
        modified = Date()
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name)
        aCoder.encode(self.modified)
    }
 
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        // Initialize the first page & set it as the current page
        let loadedName = aDecoder.decodeObject() as? String
        let loadedModified = aDecoder.decodeObject() as? Date
        self.name = loadedName
        self.modified = loadedModified
    }

    
    init(name: String){
        self.name = name
        self.modified = Date()
    }
    
}
