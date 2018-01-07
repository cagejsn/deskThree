//
//  SelectedStrokeEraser.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

class SelectedStrokeEraser: NSObject {
    
    weak var page: Paper?
    weak var listener: HandledActionListener!
    
    func clipperDidSelectStrokesForErasure(selection: CGPath){
        
    }
    
    
    init(_ ownerPage: Paper) {
        self.page = ownerPage
        super.init()
    }
}
