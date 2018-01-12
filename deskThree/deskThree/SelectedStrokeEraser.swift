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
        let state = page?.drawingView.state!
        let strokesAmbig = state!.everyVisibleStroke()
        
        guard let strokes = strokesAmbig as? [JotStroke]! else {
            return
        }
        for stroke in strokes {
           
            var i = 0
            for segmentAmbig in stroke.segments {
                
                stroke.removeElement(at: i)
                
            }
        }
        
        
        
    }
    
    
    init(_ ownerPage: Paper) {
        self.page = ownerPage
        super.init()
    }
}
