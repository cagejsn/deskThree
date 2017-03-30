//
//  DeskControlModule.swift
//  deskThree
//
//  Created by Cage Johnson on 3/29/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol DeskControlModuleDelegate {
    func fileExplorerButtonTapped(_ sender: Any)
    func saveButtonTapped(_ sender: Any)
    func loadImageButtonPushed(_ sender: Any)
    func getCurPen() -> Constants.pens
    func togglePen()
}

class DeskControlModule: DWBubbleMenuButton {
    
    var imageView: UIImageView!
    var deskViewControllerDelegate: DeskControlModuleDelegate!
    var togglePenButton: UIButton!
    
    func setup(){
        var buttons = [UIButton]()
    
        self.collapseAfterSelection = false
      
        let fileExplorerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        fileExplorerButton.setImage(UIImage(named: "fileButtonDesk"), for: .normal)
        fileExplorerButton.addTarget(self, action: #selector(DeskControlModule.fileExplorerWasTapped), for: .touchUpInside)
        buttons.append(fileExplorerButton)
        
        let saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        saveButton.setImage(UIImage(named: "saveButtonDesk"), for: .normal)
        saveButton.addTarget(self, action: #selector(DeskControlModule.saveWasTapped), for: .touchUpInside)
        buttons.append(saveButton)
        
        togglePenButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        togglePenButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        togglePenButton.addTarget(self, action: #selector(DeskControlModule.togglePenTapped), for: .touchUpInside)
        buttons.append(togglePenButton)
        
        let importPhotoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        importPhotoButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        importPhotoButton.addTarget(self, action: #selector(DeskControlModule.importPhotoWasTapped), for: .touchUpInside)
        
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
        deskViewControllerDelegate.fileExplorerButtonTapped(self)
    }
    
    func saveWasTapped(){
        deskViewControllerDelegate.saveButtonTapped(self)
    }
    
    func togglePenTapped(){
        // Change pen type
        deskViewControllerDelegate.togglePen()

        // Get the current pen type
        let curPen = deskViewControllerDelegate.getCurPen()

        // Depending on type, show the right image
        switch curPen{
        case .eraser:
            togglePenButton.setImage(UIImage(named:"eraserButtonDesk"), for: .normal)
        case .pen:
            togglePenButton.setImage(UIImage(named:"pencilButtonDesk"), for: .normal)
        }
    }
    
    func importPhotoWasTapped() {
        deskViewControllerDelegate.loadImageButtonPushed(self)
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
