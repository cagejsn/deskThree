//
//  ClipperPresenter.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

typealias AcceptsArgCompletionBlock = (CGPath)->()

protocol HandleClipsDelegate: class {
    func end()
}

protocol HandledActionListener: class {
    func actionCompleted()
}

class HandleClips: NSObject, HandledActionListener {
    
    weak var clipper: Clipper!
    var strokeToMath: StrokeToMath
    var selectedStrokeEraser: SelectedStrokeEraser
    weak var delegate: HandleClipsDelegate!
    
    func handleMath(selection: CGPath){
        
        strokeToMath.clipperDidSelectMathWith(selection: selection)
        selectedStrokeEraser.clipperDidSelectStrokesForErasure(selection: selection)
        
    }
    
    func handleClear(selection: CGPath){
        selectedStrokeEraser.clipperDidSelectStrokesForErasure(selection: selection)
        
    }
    
    func handleCancel(){
        
    }
    
    func actionCompleted(){
        delegate.end()
    }

    init(_ clipper: Clipper, currentPage: Paper) {
        self.clipper = clipper
        
        //dependencies
        strokeToMath = StrokeToMath(currentPage)
        selectedStrokeEraser = SelectedStrokeEraser(currentPage)
        
        super.init()
        strokeToMath.listener = self
        selectedStrokeEraser.listener = self
        
        
        clipper.handleClips = self
    }
}
