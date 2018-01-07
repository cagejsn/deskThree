//
//  ClipperSession.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation



class ClipperSession: NSObject, HandleClipsDelegate, ClipperDelegate {
   
    weak var sender: UIButton?
    var magicWandEnabled: Bool = false
    var handleClips: HandleClips!
    var clipper: Clipper?
    weak var ownerPage: Paper?
    
    func start() {
        addClipperToCurrentPage()
        sender?.isSelected = true
    }
    
    func addClipperToCurrentPage(){
        clipper = Clipper(overSubview: ownerPage!)
        clipper!.delegate = self
        handleClips = HandleClips(clipper!,currentPage: ownerPage!)
        handleClips.delegate = self
        ownerPage!.addSubview(clipper!)
    }
    
    func end() {
        clipper?.removeFromSuperview()
        magicWandEnabled = false
        sender!.isSelected = false
    }
    
    init(_ sender: UIButton, _ paper: Paper){
        self.sender = sender
        self.ownerPage = paper        
    }    
}
