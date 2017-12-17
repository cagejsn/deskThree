//
//  HeaderView.swift
//  deskThree
//
//  Created by Cage Johnson on 10/21/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

typealias Action = ()->()

class FileExplorerHeaderView: ILTranslucentView {
    
    var bottomBorder: CALayer?
   // var userView: UserView!
    var cancelButton: UIButton!
    var fileExplorerLabel: UILabel!
    
    var passCancel: Action!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeCancelButton()
        makeFileExplorerLabel()
        stylize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeCancelButton()
        makeFileExplorerLabel()
        stylize()
    }
    
    func handleExitButton(){
        passCancel()
    }
    
    func makeFileExplorerLabel(){
        fileExplorerLabel = UILabel()
        fileExplorerLabel.frame = CGRect(x:1,y:1,width:1,height:1)
        fileExplorerLabel.backgroundColor = UIColor.clear
        fileExplorerLabel.text = "File Explorer"
        fileExplorerLabel.textColor = UIColor.white
        
        self.addSubview(fileExplorerLabel)
        //self.translatesAutoresizingMaskIntoConstraints = false
        fileExplorerLabel.translatesAutoresizingMaskIntoConstraints = false
        let fileExplorerLabelConstraints: [NSLayoutConstraint] = {
            () -> [NSLayoutConstraint] in
            var constraints = [NSLayoutConstraint]()
            
            constraints.append(NSLayoutConstraint(item: fileExplorerLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: fileExplorerLabel, attribute:.top , relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: fileExplorerLabel, attribute:.width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1.0, constant: 100))
            constraints.append(NSLayoutConstraint(item: fileExplorerLabel, attribute:.bottom , relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
            for constraint in constraints {
                if let cons = constraint as? NSLayoutConstraint {
                    cons.isActive = true
                }
            }
            return constraints
        }()
        self.addConstraints(fileExplorerLabelConstraints)
    }
    
    func makeCancelButton(){        
        cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x:1,y:1,width:1,height:1)
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.setTitle("< Back", for: .normal)
        cancelButton.addTarget(self, action: #selector(handleExitButton), for: .touchUpInside  )
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        
        self.addSubview(cancelButton)
        //self.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let cancelButtonConstraints: [NSLayoutConstraint] = {
            () -> [NSLayoutConstraint] in
            var constraints = [NSLayoutConstraint]()
            constraints.append(NSLayoutConstraint(item: cancelButton, attribute:.leading , relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: cancelButton, attribute:.top , relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
            constraints.append(NSLayoutConstraint(item: cancelButton, attribute:.width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute , multiplier: 1.0, constant: 100))
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
//        bottomBorder = addAndReturnBottomBorder(color: FileExplorerColors.DarkGrey, width: 1)
        
        
        self.translucentAlpha = 0.8;
        self.translucentStyle = .default
        self.translucentTintColor = DeskColors.DeskBlueBarColor
        self.backgroundColor = UIColor.clear
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
