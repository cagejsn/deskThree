//
//  trash.swift
//  deskThree
//
//  Created by test on 1/20/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import UIKit

class Trash: UIImageView {
    
    //MARK: Initializers
    
    init() {
        super.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        self.image = UIImage(named: "recycle")
        self.isOpaque = false
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTrash(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: 0))
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1.0, constant: -44))
    }
 
    func open() {
        self.image = UIImage(named: "recycleGreen")
    }
    func closed() {
        self.image = UIImage(named: "recycle")
    }
    
    func unhide() {
        self.isHidden = false
    }
    
    func hide(){
        self.isHidden = true
    }
}
