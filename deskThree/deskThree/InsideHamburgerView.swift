//
//  InsideHamburgerView.swift
//  deskThree
//
//  Created by Cage Johnson on 4/25/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol InsideHamburgerViewDelegate {
    func newButtonTapped()
    func openButtonTapped()
    func printButtonTapped()
    func penSizeSliderValueChanged(value: Float)
    func penColorChanged(to: SelectedPenColor)
    func changePaper(to: SelectedPaperType)
    func importPhotoButtonTapped()
    func feedbackButtonTapped()
    func clearButtonTapped()

}

enum SelectedPenColor {
    case black
    case red
    case blue
    case green
}

enum SelectedPaperType: Int{
    case graph
    case engineering
    case lined
    
    
}

class InsideHamburgerView: UIView {
    
    @IBOutlet var blackPenColorButton: UIButton!
    @IBOutlet var redPenColorButton: UIButton!
    @IBOutlet var bluePenColorButton: UIButton!
    @IBOutlet var greenPenColorButton: UIButton!

    @IBOutlet var graphPaperButton: UIButton!
    @IBOutlet var engineeringPaperButton: UIButton!
    @IBOutlet var linedPaperButton: UIButton!
    
    
    var delegate: InsideHamburgerViewDelegate!
    
    var selectedPenColor: SelectedPenColor = .black
    var selectedPaperType: SelectedPaperType = .graph
    
    func unselect(_ previous: SelectedPaperType){
        switch previous {
        case .graph:
            graphPaperButton.layer.borderWidth = 0
        case .engineering:
            engineeringPaperButton.layer.borderWidth = 0
        case .lined:
            linedPaperButton.layer.borderWidth = 0
        default:
            return
        }

    }
    
    func changePaper(to: SelectedPaperType){
        
        
        switch to {
        case .graph:
            graphPaperButton.layer.borderWidth = 2
            graphPaperButton.layer.borderColor = Constants.DesignColors.deskBlue.cgColor
            selectedPaperType = .graph
        case .engineering:
            engineeringPaperButton.layer.borderWidth = 2
            engineeringPaperButton.layer.borderColor = Constants.DesignColors.deskBlue.cgColor
            selectedPaperType = .engineering
        case .lined:
            linedPaperButton.layer.borderWidth = 2
            linedPaperButton.layer.borderColor = Constants.DesignColors.deskBlue.cgColor
            selectedPaperType = .lined
        default:
            return
        }
        delegate.changePaper(to: selectedPaperType)
    }
    
    func removeSelectedIcon(from: SelectedPenColor){
        switch from {
        case .black:
            blackPenColorButton.setImage(nil, for: .normal)
        case .red:
            redPenColorButton.setImage(nil, for: .normal)
        case .blue:
            bluePenColorButton.setImage(nil, for: .normal)
        case .green:
            greenPenColorButton.setImage(nil, for: .normal)
        default:
            return
        }
    }
    
    func penColorChanged(to:SelectedPenColor){
        switch to {
        case .black:
            blackPenColorButton.setImage(UIImage(named:"penColorSelected"), for: .normal)
            selectedPenColor = .black
        case .red:
            redPenColorButton.setImage(UIImage(named:"penColorSelected"), for: .normal)
            selectedPenColor = .red
        case .blue:
            bluePenColorButton.setImage(UIImage(named:"penColorSelected"), for: .normal)
            selectedPenColor = .blue
        case .green:
            greenPenColorButton.setImage(UIImage(named:"penColorSelected"), for: .normal)
            selectedPenColor = .green
        default:
            return
        }
        delegate.penColorChanged(to: selectedPenColor)
    }
    
    
    @IBAction func newButtonTapped(_ sender: Any) {
        delegate.newButtonTapped()
    }
    
    @IBAction func openButtonTapped(_ sender: Any) {
        delegate.openButtonTapped()
    }
    
    @IBAction func printButtonTapped(_ sender: Any) {
        delegate.printButtonTapped()
    }
    
    @IBAction func penSizeSliderValueChanged(_ sender: UISlider) {
        delegate.penSizeSliderValueChanged(value: sender.value)
    }
    
    @IBAction func firstColorButtonTapped(_ sender: Any) {
        if(selectedPenColor != .black){
        removeSelectedIcon(from: selectedPenColor)
        penColorChanged(to: .black)
        }
    }
    
    @IBAction func secondColorButtonTapped(_ sender: Any) {
        if(selectedPenColor != .red){
            removeSelectedIcon(from: selectedPenColor)
            penColorChanged(to: .red)
        }
    }
    
    @IBAction func thirdColorButtonTapped(_ sender: Any) {
        if(selectedPenColor != .blue){
            removeSelectedIcon(from: selectedPenColor)
            penColorChanged(to: .blue)
        }
    }
    
    @IBAction func fourthColorButtonTapped(_ sender: Any) {
        if(selectedPenColor != .green){
            removeSelectedIcon(from: selectedPenColor)
            penColorChanged(to: .green)
        }
    }
    
    @IBAction func firstBackgroundButtonTapped(_ sender: Any) {
        if(selectedPaperType != .graph){
            unselect(selectedPaperType)
            changePaper(to: .graph)
            
        }
    }
    
    @IBAction func secondBackgroundButtonTapped(_ sender: Any) {
        if(selectedPaperType != .engineering){
            unselect(selectedPaperType)
            changePaper(to: .engineering)
        }
    }
    
    @IBAction func thirdBackgroundButtonTapped(_ sender: Any) {
        if(selectedPaperType != .lined){
            unselect(selectedPaperType)
            changePaper(to: .lined)
        }
    }
    
    
    @IBAction func importPhotoButtonTapped(_ sender: Any) {
        delegate.importPhotoButtonTapped()
    }
    
    @IBAction func feedbackButtonTapped(_ sender: Any) {
        delegate.feedbackButtonTapped()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        delegate.clearButtonTapped()    
    }
    
    func setup(){
        penColorChanged(to: selectedPenColor)
        changePaper(to: selectedPaperType)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
