//
//  FileExplorerCollectionView.swift
//  deskThree
//
//  Created by Cage Johnson on 10/1/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class FileExplorerCollectionView: UICollectionView {
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        stylize()
        
    }
    
    
    func stylize(){
        self.layer.cornerRadius = 10
        //self.backgroundColor = UIColor.darkGray
    }
    
    
    
}
