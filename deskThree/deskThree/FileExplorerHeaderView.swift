//
//  HeaderView.swift
//  deskThree
//
//  Created by Cage Johnson on 10/21/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class FileExplorerHeaderView: UIView {
    
    var bottomBorder: CALayer?
    var userView: UserView!
    var cancelButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeCancelButton()
        stylize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeCancelButton()
        stylize()
    }
    
    func makeCancelButton(){
        
        cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x:1,y:1,width:1,height:1)
        cancelButton.backgroundColor = UIColor.blue
        self.addSubview(cancelButton)
        //self.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelButtonConstraints: [NSLayoutConstraint] = {
            () -> [NSLayoutConstraint] in
            var constraints = [NSLayoutConstraint]()
            constraints.append(NSLayoutConstraint(item: cancelButton, attribute:.trailing , relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: cancelButton, attribute:.top , relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: cancelButton, attribute:.width, relatedBy: .equal, toItem: self, attribute: .height , multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: cancelButton, attribute:.bottom , relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
            for constraint in constraints {
                if let cons = constraint as? NSLayoutConstraint {
                    cons.isActive = true
                }
            }
            return constraints
        }()
        self.addConstraints(cancelButtonConstraints)
        
        
        
    }
   
    func stylize(){
        bottomBorder = addAndReturnBottomBorder(color: FileExplorerColors.DarkGrey, width: 2)
        backgroundColor = FileExplorerColors.LightGrey
    }
    
    func removeBorders(){
        bottomBorder?.removeFromSuperlayer()
        bottomBorder = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        removeBorders()
        stylize()
    }
    
    
    
    
}