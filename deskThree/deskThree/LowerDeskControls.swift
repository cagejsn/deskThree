//
//  LowerDeskControls.swift
//  deskThree
//
//  Created by Cage Johnson on 3/30/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation



class LowerDeskControls: UIView {
    
    var delegate: DeskControlModuleDelegate!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        }
    
    @IBAction func lastPageTapped(_ sender: Any) {
        delegate.lastPageTapped(self)
    }

    @IBAction func undoTapped(_ sender: Any) {
        delegate.undoTapped(self)
    }
  
    @IBAction func redoTapped(_ sender: Any) {
        delegate.redoTapped(self)
    }
    
    @IBAction func nextPageTapped(_ sender: Any) {
        delegate.nextPageTapped(self)
    }
}
