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
        super.init(frame: CGRect(x: 128, y: 128, width: 128, height: 128))
        self.image = UIImage(named: "icon-trash-b")
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTrash(lowerView: UIView){
        self.translatesAutoresizingMaskIntoConstraints = false
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: 0))
        superview!.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: lowerView, attribute: .top, multiplier: 1.0, constant: 0))
    }
    
    func devourExpressionEffects(){
    }
 
    func open() {
        self.image = UIImage(named: "icon-trash-redup")
    }
    func close() {
        self.image = UIImage(named: "icon-trash-b")
    }
    
    func unhide() {
        self.isHidden = false
    }
    
    func hide(){
        self.isHidden = true
    }
}
