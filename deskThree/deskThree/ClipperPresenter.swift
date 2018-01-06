//
//  ClipperPresenter.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

typealias AcceptsArgCompletionBlock = (CGPath)->()

class ClipperPresenter: NSObject {
    
    var clipper: Clipper
    var strokeToMath: StrokeToMath
    var selectedStrokeEraser: SelectedStrokeEraser
    
    
    
    func showSelectableOptions(forRect: CGRect){
        clipper.becomeFirstResponder()
        var selectActionMenu: UIMenuController = UIMenuController.shared
        selectActionMenu.arrowDirection = .down
        selectActionMenu.setTargetRect(forRect, in: clipper)
        var selectableActionMath = UIMenuItem(title: "math", action: #selector(mathButtonTapped))
        var selectableActionClear = UIMenuItem(title: "clear", action: #selector(clearButtonTapped))
        var selectableActionCancel = UIMenuItem(title: "cancel", action: #selector(cancelButtonTapped))
        selectActionMenu.menuItems = [selectableActionMath,selectableActionClear,selectableActionCancel]
        selectActionMenu.setMenuVisible(true, animated: true)
    }
    
    func mathButtonTapped(){
        var jotToMath = StrokeToMath.setupJotToMath(pathFrame: clipper.activePath.bounds)
    }
    
    func clearButtonTapped(){
        
    }
    
    func cancelButtonTapped(){
        
    }
    
    
    
    
    init(_ clipper: Clipper) {
        self.clipper = clipper
        super.init()
    }
    
    
}
