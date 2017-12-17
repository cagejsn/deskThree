//
//  FileThumbnailImageView.swift
//  deskThree
//
//  Created by Cage Johnson on 12/16/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class FileThumbnailButton: UIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 40, 0)
        self.setImage(#imageLiteral(resourceName: "deskLogo"), for: .normal)
        self.imageView?.contentMode = .scaleAspectFill
    }
    
    
    
    
}
