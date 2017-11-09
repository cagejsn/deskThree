//
//  FileExplorerCollectionViewHeader.swift
//  deskThree
//
//  Created by Cage Johnson on 11/9/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class FileExplorerCollectionViewHeader: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = FileExplorerColors.LightGrey
    }
    
    
    
}
