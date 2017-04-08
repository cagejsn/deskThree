//
//  DeskControlModule.swift
//  deskThree
//
//  Created by Cage Johnson on 3/29/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import Mixpanel

protocol DeskControlModuleDelegate {
    func fileExplorerButtonTapped(_ sender: Any)
    func saveButtonTapped(_ sender: Any)
    func loadImageButtonPushed(_ sender: Any)
    func mathFormulaButtonTapped(_ sender: Any)
    func printButtonPushed(_ sender: Any)
    func clearButtonTapped(_ sender: AnyObject)
    func getCurPen() -> Constants.pens
    func togglePen()
    func togglePenColor()
    
    // These funcs are called by lowerDeskControlModule
    func lastPageTapped(_ sender: Any)
    func undoTapped(_ sender: Any)
    func redoTapped(_ sender: Any)
    func nextPageTapped(_ sender: Any)
    func getCurPenColor() -> UIColor
    
}

class DeskControlModule: DWBubbleMenuButton {
    
    var imageView: UIImageView!
    var deskViewControllerDelegate: DeskControlModuleDelegate!
    var togglePenButton: UIButton!
    var changePenColorButton: UIButton!

    // Mixpanel initialization
    var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")

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
        
        changePenColorButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        changePenColorButton.setImage(UIImage(named: "penColorButtonBlack"), for: .normal)
        changePenColorButton.addTarget(self, action: #selector(DeskControlModule.changePenColorButtonWasTapped), for: .touchUpInside)
        buttons.append(changePenColorButton)
        
        
        let importPhotoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        importPhotoButton.setImage(UIImage(named: "cameraButton"
        ), for: .normal)
        importPhotoButton.addTarget(self, action: #selector(DeskControlModule.importPhotoButtonWasTapped), for: .touchUpInside)
        buttons.append(importPhotoButton)

        let toggleMyScriptViewButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        toggleMyScriptViewButton.setImage(UIImage(named: "fOfXButton"), for: .normal)
        toggleMyScriptViewButton.addTarget(self, action: #selector(DeskControlModule.toggleMyScriptViewButtonWasTapped), for: .touchUpInside)
        buttons.append(toggleMyScriptViewButton)

        let exportPageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        exportPageButton.setImage(UIImage(named: "printButton"), for: .normal)
        exportPageButton.addTarget(self, action: #selector(DeskControlModule.exportPageButtonWasTapped), for: .touchUpInside)
        buttons.append(exportPageButton)
        
        let clearPageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        clearPageButton.setImage(UIImage(named: "clearButton"), for: .normal)
        clearPageButton.addTarget(self, action: #selector(DeskControlModule.clearPageButtonWasTapped), for: .touchUpInside)
        buttons.append(clearPageButton)
        

        self.addButtons(buttons)
    }
    
    override func showButtons() {
        // Mixpanel event
        mixpanel.track(event: "Button: Show Buttons")

        super.showButtons()
        imageView.image = UIImage(named: "lessButton")
    }
    
    override func dismissButtons() {
        // Mixpanel event
        mixpanel.track(event: "Button: Dismiss Buttons")

        super.dismissButtons()
        imageView.image = UIImage(named: "moreButton")
    }
    
    func fileExplorerButtonWasTapped(){
        // Mixpanel event
        mixpanel.track(event: "Button: File Explorer")

        deskViewControllerDelegate.fileExplorerButtonTapped(self)
    }
    
    func saveButtonWasTapped(){
        // Mixpanel event
        mixpanel.track(event: "Button: Save")

        deskViewControllerDelegate.saveButtonTapped(self)
    }
    
    func togglePenButtonWasTapped(){
        // Mixpanel event
        mixpanel.track(event: "Button: Pen Toggle")

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
        // Mixpanel event
        mixpanel.track(event: "Button: Load Image")

        deskViewControllerDelegate.loadImageButtonPushed(self)
    }
    
    func toggleMyScriptViewButtonWasTapped() {
        // Mixpanel event
        mixpanel.track(event: "Button: MyScript Box")

        deskViewControllerDelegate.mathFormulaButtonTapped(self)
    }
    
    func exportPageButtonWasTapped() {
        // Mixpanel event
        mixpanel.track(event: "Button: Print")

        deskViewControllerDelegate.printButtonPushed(self)
    }
    
    func changePenColorButtonWasTapped(){
        // Mixpanel event
        mixpanel.track(event: "Button: Pen Color Toggle")

        deskViewControllerDelegate.togglePenColor()
        // Get the current pen color
        let curColor = deskViewControllerDelegate.getCurPenColor()
        
        // Depending on type, show the right image
        switch curColor{
        case UIColor.black:
            // Mixpanel event
            mixpanel.track(event: "Pen Color: Black")

            changePenColorButton.setImage(UIImage(named:"penColorButtonBlack"), for: .normal)
            break
        case UIColor.red:
            // Mixpanel event
            mixpanel.track(event: "Pen Color: Red")

            changePenColorButton.setImage(UIImage(named:"penColorButtonRed"), for: .normal)
            break
        default:
            return
        }
    }
    
    func clearPageButtonWasTapped() {
        // Mixpanel event
        mixpanel.track(event: "Button: Clear Page")

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
