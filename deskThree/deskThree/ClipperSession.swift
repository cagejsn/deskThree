//
//  ClipperSession.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

class ClipperSession: NSObject {
    
    weak var sender: UIButton?
    var magicWandEnabled: Bool = false
    var clipperPresenter: ClipperPresenter
    var clipper: Clipper?
    var hasClipperBegunClipping: Bool = false
    weak var ownerPage: Paper?
    
    
    func start() {
        addClipperToCurrentPage()
        sender!.isSelected = true
        hasClipperBegunClipping = true
    }
    
    func addClipperToCurrentPage(){
        clipper = Clipper(overSubview: ownerPage!)
        clipperPresenter = ClipperPresenter(clipper)
        ownerPage!.addSubview(clipper!)
        
    }
    
    func end() {
        sender!.isSelected = false
    }
    
    init(_ sender: UIButton, _ paper: Paper){
        self.sender = sender
        self.ownerPage = paper        
    }
    
    
    
}
