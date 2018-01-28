//
//  DeskUserPrefs.swift
//  deskThree
//
//  Created by Cage Johnson on 1/13/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

let DEFAULT_GROUPING_NAME: String = "DefaultGroupingName"

class DeskUserPrefs {
    
    static func nameOfDefaultGrouping() -> String {
        let userDefaults = UserDefaults.standard
        var string = userDefaults.string(forKey: DEFAULT_GROUPING_NAME)
        
        if string == nil {
            string = "My Desk"
        }
        return string!
    }
    
}
