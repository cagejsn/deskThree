//
//  DeskControlModule.swift
//  deskThree
//
//  Created by Cage Johnson on 3/29/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class DeskControlModule: DWBubbleMenuButton {
    
    var imageView: UIImageView!
    
    func setup(){
    
        var buttons = [UIButton]()
        
      
        var fileExplorerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        fileExplorerButton.setImage(UIImage(named: "fileButtonDesk"), for: .normal)
        fileExplorerButton.addTarget(self, action: #selector(DeskControlModule.fileExplorerWasTapped), for: .touchUpInside)
        buttons.append(fileExplorerButton)
        
        var saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        saveButton.setImage(UIImage(named: "saveButtonDesk"), for: .normal)
        saveButton.addTarget(self, action: #selector(DeskControlModule.saveWasTapped), for: .touchUpInside)
        buttons.append(saveButton)
        
        var togglePenButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        togglePenButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        togglePenButton.addTarget(self, action: #selector(DeskControlModule.togglePenTapped), for: .touchUpInside)
        buttons.append(togglePenButton)

        
        
        self.addButtons(buttons)
    }
    
    override func showButtons() {
        super.showButtons()
        imageView.image = UIImage(named: "lessButton")
        
    }
    
    override func dismissButtons() {
        super.dismissButtons()
        imageView.image = UIImage(named: "moreButton")
    }
    
    
    func fileExplorerWasTapped(){
        
    }
    
    func saveWasTapped(){
        
    }
    
    func togglePenTapped(){
        
    }
    
    
     override init(frame: CGRect) {
        super.init(frame: frame, expansionDirection: .DirectionDown)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.image = UIImage(named: "moreButton")
        self.homeButtonView = imageView
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
