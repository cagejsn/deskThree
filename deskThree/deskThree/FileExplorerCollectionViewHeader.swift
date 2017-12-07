//
//  FileExplorerCollectionViewHeader.swift
//  deskThree
//
//  Created by Cage Johnson on 11/9/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class FileExplorerCollectionViewHeader: UIView {
    
    var bottomBorder: CALayer!
    var currentGroupingLabel: CurrentGroupingLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCurrentGroupingLabel()
        stylize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.white
        createCurrentGroupingLabel()
        stylize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        removeAndReplaceBorder()
    }
    
    func createCurrentGroupingLabel(){
        currentGroupingLabel = CurrentGroupingLabel()
        currentGroupingLabel.frame = CGRect()
        currentGroupingLabel.backgroundColor = UIColor.clear
        currentGroupingLabel.textColor = FileExplorerColors.DarkTextColor
        currentGroupingLabel.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightBold)
        
        self.addSubview(currentGroupingLabel)
                currentGroupingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentGroupingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            currentGroupingLabel.topAnchor.constraint(equalTo: topAnchor),
            currentGroupingLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            currentGroupingLabel.widthAnchor.constraint(equalToConstant: 300)
            ])
    }
    
    func setCurrentGroupingLabelText(text: String){
        currentGroupingLabel.text = text
    }
    
    func removeAndReplaceBorder(){
        bottomBorder.removeFromSuperlayer()
        bottomBorder = nil
        stylize()
    }
    
    func stylize(){
        bottomBorder = addAndReturnBottomBorder(color: FileExplorerColors.LightGrey, width: 1)
    }
    
    
}
