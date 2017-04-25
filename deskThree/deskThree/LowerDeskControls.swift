//
//  LowerDeskControls.swift
//  deskThree
//
//  Created by Cage Johnson on 3/30/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
#if !DEBUG
    import Mixpanel
#endif

class LowerDeskControls: UIView {
    
    weak var delegate: PageAndDrawingDelegate!
    
    #if !DEBUG
        var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
    }
    
    @IBAction func lastPageTapped(_ sender: Any) {
        #if !DEBUG
            mixpanel.track(event: "Button: Page Left")
        #endif

        delegate.movePage(direction: "left")
    }

    @IBAction func undoTapped(_ sender: Any) {
        #if !DEBUG
            mixpanel.track(event: "Button: Undo")
        #endif

        delegate.undoTapped(self)
    }
  
    @IBAction func redoTapped(_ sender: Any) {
        #if !DEBUG
            mixpanel.track(event: "Button: Redo")
        #endif
        
        delegate.redoTapped(self)
    }
    
    @IBAction func nextPageTapped(_ sender: Any) {
        #if !DEBUG
            mixpanel.track(event: "Button: Page Right")
        #endif
        
        delegate.movePage(direction: "right")
    }
}
