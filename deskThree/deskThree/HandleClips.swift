//
//  ClipperPresenter.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

typealias AcceptsArgCompletionBlock = (CGPath)->()

protocol HandleClipsDelegate {
    func end()
}

class HandleClips: NSObject {
    
    var clipper: Clipper
    var strokeToMath: StrokeToMath
    var selectedStrokeEraser: SelectedStrokeEraser
    var delegate: HandleClipsDelegate!
    
    func handleMath(selection: CGPath){
        strokeToMath.clipperDidSelectMathWith(selection: selection)
        selectedStrokeEraser.clipperDidSelectStrokesForErasure(selection: selection)
        delegate.end()
    }
    
    func handleClear(selection: CGPath){
        selectedStrokeEraser.clipperDidSelectStrokesForErasure(selection: selection)
        delegate.end()
    }
    
    func handleCancel(){
        delegate.end()
    }

    init(_ clipper: Clipper, currentPage: Paper) {
        self.clipper = clipper
        
        //dependencies
        strokeToMath = StrokeToMath(currentPage)
        selectedStrokeEraser = SelectedStrokeEraser(currentPage)
        
        super.init()
        clipper.handleClips = self
    }
}
