//
//  NewCollectionViewCell.swift
//  deskThree
//
//  Created by Cage Johnson on 12/6/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class NewCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var translucentView: ILTranslucentView!
    
    @IBOutlet var marchingAntsOnBorderView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        translucentView.translucentAlpha = 0.8;
        translucentView.translucentStyle = .default
        translucentView.translucentTintColor = UIColor.init(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
        translucentView.backgroundColor = UIColor.clear
        
        
        
        
        
        
    }
}
