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
    func mathFormulaButtonTapped(_ sender: Any)
    func printButtonPushed(_ sender: Any)
    func clearButtonTapped(_ sender: AnyObject)
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
        fileExplorerButton.addTarget(self, action: #selector(DeskControlModule.fileExplorerButtonWasTapped), for: .touchUpInside)
        buttons.append(fileExplorerButton)
        
        let saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        saveButton.setImage(UIImage(named: "saveButtonDesk"), for: .normal)
        saveButton.addTarget(self, action: #selector(DeskControlModule.saveButtonWasTapped), for: .touchUpInside)
        buttons.append(saveButton)
        
        togglePenButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        togglePenButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        togglePenButton.addTarget(self, action: #selector(DeskControlModule.togglePenButtonWasTapped), for: .touchUpInside)
        buttons.append(togglePenButton)
        
        let importPhotoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        importPhotoButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        importPhotoButton.addTarget(self, action: #selector(DeskControlModule.importPhotoButtonWasTapped), for: .touchUpInside)
        buttons.append(importPhotoButton)

        let toggleMyScriptViewButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        toggleMyScriptViewButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        toggleMyScriptViewButton.addTarget(self, action: #selector(DeskControlModule.toggleMyScriptViewButtonWasTapped), for: .touchUpInside)
        buttons.append(toggleMyScriptViewButton)

        let exportPageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        exportPageButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        exportPageButton.addTarget(self, action: #selector(DeskControlModule.exportPageButtonWasTapped), for: .touchUpInside)
        buttons.append(exportPageButton)
        
        let clearPageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        clearPageButton.setImage(UIImage(named: "pencilButtonDesk"), for: .normal)
        clearPageButton.addTarget(self, action: #selector(DeskControlModule.clearPageButtonWasTapped), for: .touchUpInside)
        buttons.append(clearPageButton)
        
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
    
    func fileExplorerButtonWasTapped(){
        deskViewControllerDelegate.fileExplorerButtonTapped(self)
    }
    
    func saveButtonWasTapped(){
        deskViewControllerDelegate.saveButtonTapped(self)
    }
    
    func togglePenButtonWasTapped(){
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
    
    func importPhotoButtonWasTapped() {
        deskViewControllerDelegate.loadImageButtonPushed(self)
    }
    
    func toggleMyScriptViewButtonWasTapped() {
        deskViewControllerDelegate.mathFormulaButtonTapped(self)
    }
    
    func exportPageButtonWasTapped() {
        deskViewControllerDelegate.printButtonPushed(self)
    }
    
    func clearPageButtonWasTapped() {
        deskViewControllerDelegate.clearButtonTapped(self)
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
