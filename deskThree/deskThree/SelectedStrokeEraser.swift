//
//  SelectedStrokeEraser.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

class SelectedStrokeEraser: NSObject {
    
    var page: Paper
    
    
    func clipperDidSelectStrokesForErasure(selection: CGPath){
        
    }
    
    
    init(_ ownerPage: Paper) {
        self.page = ownerPage
        super.init()
    }
}
