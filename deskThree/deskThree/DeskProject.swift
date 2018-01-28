//
//  DeskProject.swift
//  deskThree
//
//  Created by test on 3/18/17.Grou
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

let SERIAL_NUMBER_KEY_STRING = "serialNumber"

class DeskProject: NSObject, NSCoding {
    
    var name: String!
    private var modified: Date!
    private var createdTimeStamp: Date = Date()
    var isEdited: Bool = false
    var ownedByGrouping: String
    lazy var uniqueSerialNumber: Int = self.makeHashNumberBasedOnGroupingAndName()
    
    func edit() {
        isEdited = true
    }
    
    //overrides the == operator
    override func isEqual(_ object: Any?) -> Bool {
        if(self.getUniqueProjectSerialNumber() == (object as? DeskProject)?.getUniqueProjectSerialNumber()){
            return true
        }
        return false
    }
    
    func getUniqueProjectSerialNumber() -> Int {
        return uniqueSerialNumber
    }
    
    private func makeHashNumberBasedOnGroupingAndName() -> Int {
        let serialNumber = name.hashValue ^ ownedByGrouping.hashValue ^ createdTimeStamp.hashValue
        return serialNumber
    }
    
    ///change name of project
    func rename(name: String){
        self.name = name
        uniqueSerialNumber = makeHashNumberBasedOnGroupingAndName()
    }
    
    func getName()-> String {
        return name
    }
    
    ///update modified date to today
    func modify(){
        modified = Date()
    }
    
    func getOwnedByGroupingName() -> String {
        return ownedByGrouping
    }
    
    func setOwnedByGroupingName(newGroupingOwner: String) {
        ownedByGrouping = newGroupingOwner
        uniqueSerialNumber = makeHashNumberBasedOnGroupingAndName()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name)
        aCoder.encode(self.createdTimeStamp)
        aCoder.encode(self.modified)
        aCoder.encode(self.ownedByGrouping)
    }
 
    required init?(coder aDecoder: NSCoder) {
        isEdited = true
        let loadedName = aDecoder.decodeObject() as? String
        let loadedDateCreated = aDecoder.decodeObject() as? Date
        let loadedModified = aDecoder.decodeObject() as? Date
        let loadedOwnedByGrouping = aDecoder.decodeObject() as? String
        self.name = loadedName
        self.createdTimeStamp = loadedDateCreated!
        self.modified = loadedModified
        self.ownedByGrouping = loadedOwnedByGrouping!
    }
    
    init(name: String, ownedByGrouping: String){
        self.name = name
        self.createdTimeStamp = Date()
        self.modified = Date()
        self.ownedByGrouping = ownedByGrouping
    }
}
