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
    
    init(name: String){
        self.name = name
        self.modified = Date()
    }
    
    func modify(){
        modified = Date()
    }
    
}
