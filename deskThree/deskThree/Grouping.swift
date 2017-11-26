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
    var projects: [DeskProject]?
    var color: UIColor = UIColor.gray
    
    ///change name of grouping
    func rename(name: String){
        self.name = name
    }
    
    func getName()->String {
        return name!
    }
    
    func getProjects() -> [DeskProject]?{
        return projects
    }
    
    func addProject(_ project: DeskProject){
        self.projects!.append(project)
    }
    
    func setColor(color:UIColor){
        self.color = color
    }
    
    func getColor() -> UIColor {
        return self.color
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name)
        aCoder.encode(self.projects)
        aCoder.encode(self.color)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        // Initialize the first page & set it as the current page
        let loadedName = aDecoder.decodeObject() as! String
        let loadedProjects = aDecoder.decodeObject() as? [DeskProject]
        let loadedColor = aDecoder.decodeObject() as? UIColor
        self.name = loadedName
        self.projects = loadedProjects
    }
    
    init(name: String = "default"){
        self.name = name
        self.projects = [DeskProject]()
//        self.color = UIColor.gray
    }
}
