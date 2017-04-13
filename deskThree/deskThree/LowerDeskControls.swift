//
//  LowerDeskControls.swift
//  deskThree
//
//  Created by Cage Johnson on 3/30/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Mixpanel

class LowerDeskControls: UIView {
    
    var delegate: PageAndDrawingDelegate!
    
    // Mixpanel initialization
    var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
    }
    
    @IBAction func lastPageTapped(_ sender: Any) {
        // Mixpanel event
        mixpanel.track(event: "Button: Page Left")

        delegate.movePage(direction: "left")
    }

    @IBAction func undoTapped(_ sender: Any) {
        delegate.undoTapped(self)
    }
  
    @IBAction func redoTapped(_ sender: Any) {
        delegate.redoTapped(self)
    }
    
    @IBAction func nextPageTapped(_ sender: Any) {
        // Mixpanel event
        mixpanel.track(event: "Button: Page Right")
        
        delegate.movePage(direction: "right")
    }
}
