//
//  FileExplorerCollectionViewCell.swift
//  deskThree
//
//  Created by Cage Johnson on 10/1/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class FileExplorerCollectionViewCell: UICollectionViewCell {
    
    fileprivate var fileImage: UIImageView!
    fileprivate var fileName: UILabel!
    fileprivate var newIconView: UIView!
    fileprivate var gradeLabel: UILabel!
    fileprivate var dueDateView: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        fileImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        fileImage.image = #imageLiteral(resourceName: "apple")
        
        
        
        fileName = UILabel(frame: CGRect(x: 0, y: self.frame.height / 5, width: self.frame.width, height:  3 * (self.frame.height / 5)))
        fileName.text = "HW1"
        fileName.textColor = UIColor.white
        fileName.textAlignment = .center
        
        gradeLabel = UILabel(frame: CGRect(x: self.frame.height / 8, y: 9*(self.frame.height / 10), width: 3*(self.frame.width/4), height: (self.frame.height / 5)))
        gradeLabel.text = "96/100"
        gradeLabel.textColor = UIColor.white
        gradeLabel.textAlignment = .center
        
        
        self.addSubview(fileImage)
        self.addSubview(fileName)
        self.addSubview(gradeLabel)
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
