//
//  DeskProject.swift
//  deskThree
//
//  Created by test on 3/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class DeskProject{
    
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
    
    init(name: String){
        self.name = name
        self.modified = Date()
    }
    
}
