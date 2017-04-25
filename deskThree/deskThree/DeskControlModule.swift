//
//  DeskControlModule.swift
//  deskThree
//
//  Created by Cage Johnson on 3/29/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
#if !DEBUG
    import Mixpanel
#endif

protocol DeskControlModuleDelegate {
    func fileExplorerButtonTapped(_ sender: Any)
    func saveButtonTapped(_ sender: Any)
    func loadImageButtonPushed(_ sender: Any)
    func mathFormulaButtonTapped(_ sender: Any)
    func printButtonPushed(_ sender: Any)
    func feedbackButtonTapped(_ sender: Any)
}

protocol PageAndDrawingDelegate {
    func clearButtonTapped(_ sender: AnyObject)
    func getCurPen() -> Constants.pens
    func togglePen()
    func togglePenColor()
    
    // These funcs are called by lowerDeskControlModule
   
    func getCurPenColor() -> UIColor
}

class DeskControlModule: DWBubbleMenuButton {
    
    var imageView: UIImageView!
    var deskViewControllerDelegate: DeskControlModuleDelegate!
    var pageAndDrawingDelegate: PageAndDrawingDelegate!
    var togglePenButton: UIButton!
    var changePenColorButton: UIButton!

    #if !DEBUG
        var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif

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
        
        let feedbackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        feedbackButton.setImage(UIImage(named: "feedbackButton"), for: .normal)
        feedbackButton.addTarget(self, action: #selector(DeskControlModule.feedbackButtonWasTapped), for: .touchUpInside)
        buttons.append(feedbackButton)
        

        self.addButtons(buttons)
    }
    
    func enforceControlsState(_ pen: Constants.pens, _ color: UIColor){
        
        // Depending on type, show the right image
        switch pen{
        case .eraser:
            togglePenButton.setImage(UIImage(named:"eraserButtonDesk"), for: .normal)
        case .pen:
            togglePenButton.setImage(UIImage(named:"pencilButtonDesk"), for: .normal)
        }
        
        
        // Depending on type, show the right image
        switch color{
        case UIColor.black:
            changePenColorButton.setImage(UIImage(named:"penColorButtonBlack"), for: .normal)
            break
        case UIColor.red:
            changePenColorButton.setImage(UIImage(named:"penColorButtonRed"), for: .normal)
            break
        default:
            return
        }
        
        
        
    }
    
    override func showButtons() {
        #if !DEBUG
            mixpanel.track(event: "Button: Show Buttons")
        #endif

        super.showButtons()
        imageView.image = UIImage(named: "lessButton")
    }
    
    override func dismissButtons() {
        #if !DEBUG
            mixpanel.track(event: "Button: Dismiss Buttons")
        #endif

        super.dismissButtons()
        imageView.image = UIImage(named: "moreButton")
    }
    
    func fileExplorerButtonWasTapped(){
        #if !DEBUG
            mixpanel.track(event: "Button: File Explorer")
        #endif

        deskViewControllerDelegate.fileExplorerButtonTapped(self)
    }
    
    func saveButtonWasTapped(){
        #if !DEBUG
            mixpanel.track(event: "Button: Save")
        #endif

        deskViewControllerDelegate.saveButtonTapped(self)
    }
    
    func togglePenButtonWasTapped(){
        #if !DEBUG
            mixpanel.track(event: "Button: Pen Toggle")
        #endif

        // Change pen type
        pageAndDrawingDelegate.togglePen()

        // Get the current pen type
        let curPen = pageAndDrawingDelegate.getCurPen()

        // Depending on type, show the right image
        switch curPen{
        case .eraser:
            togglePenButton.setImage(UIImage(named:"eraserButtonDesk"), for: .normal)
        case .pen:
            togglePenButton.setImage(UIImage(named:"pencilButtonDesk"), for: .normal)
        }
    }
    
    func importPhotoButtonWasTapped() {
        #if !DEBUG
            mixpanel.track(event: "Button: Load Image")
        #endif

        deskViewControllerDelegate.loadImageButtonPushed(self)
    }
    
    func toggleMyScriptViewButtonWasTapped() {
        #if !DEBUG
            mixpanel.track(event: "Button: MyScript Box")
        #endif

        deskViewControllerDelegate.mathFormulaButtonTapped(self)
    }
    
    func exportPageButtonWasTapped() {
        #if !DEBUG
            mixpanel.track(event: "Button: Print")
        #endif

        deskViewControllerDelegate.printButtonPushed(self)
    }
    
    func changePenColorButtonWasTapped(){
        #if !DEBUG
            mixpanel.track(event: "Button: Pen Color Toggle")
        #endif

        pageAndDrawingDelegate.togglePenColor()
        // Get the current pen color
        let curColor = pageAndDrawingDelegate.getCurPenColor()
        
        // Depending on type, show the right image
        switch curColor{
        case UIColor.black:
            #if !DEBUG
                mixpanel.track(event: "Pen Color: Black")
            #endif

            changePenColorButton.setImage(UIImage(named:"penColorButtonBlack"), for: .normal)
            break
        case UIColor.red:
            #if !DEBUG
                mixpanel.track(event: "Pen Color: Red")
            #endif

            changePenColorButton.setImage(UIImage(named:"penColorButtonRed"), for: .normal)
            break
        default:
            return
        }
    }

    func clearPageButtonWasTapped() {
        #if !DEBUG
            mixpanel.track(event: "Button: Clear Page")
        #endif

        pageAndDrawingDelegate.clearButtonTapped(self)
    }
    

    func feedbackButtonWasTapped() {
        #if !DEBUG
            mixpanel.track(event: "Button: Feedback")
        #endif
        
        deskViewControllerDelegate.feedbackButtonTapped(self)
    }

    init(frame: CGRect, moduleDelegate: DeskControlModuleDelegate, pageDelegate: PageAndDrawingDelegate) {
        super.init(frame: frame, expansionDirection: .DirectionDown)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.image = UIImage(named: "moreButton")
        self.homeButtonView = imageView
        setup()
        deskViewControllerDelegate = moduleDelegate
        pageAndDrawingDelegate = pageDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
