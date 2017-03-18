//
//  SaveAsView.swift
//  deskThree
//
//  Created by Cage Johnson on 3/18/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class SaveAsView: UIView {
    
    var workAreaRef: WorkArea!
    var metaDataArray: [DeskProject]?
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.removeFromSuperview()  
    }
  required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
