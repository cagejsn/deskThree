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
    func backgroundButtonTapped(index: Int)
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

class InsideHamburgerView: UIView {
    
    @IBOutlet var blackPenColorButton: UIButton!
    @IBOutlet var redPenColorButton: UIButton!
    @IBOutlet var bluePenColorButton: UIButton!
    @IBOutlet var greenPenColorButton: UIButton!

    
    var delegate: InsideHamburgerViewDelegate!
    
    var selectedPenColor: SelectedPenColor = .black
    
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
        delegate.backgroundButtonTapped(index: 0)
    }
    
    @IBAction func secondBackgroundButtonTapped(_ sender: Any) {
        delegate.backgroundButtonTapped(index: 1)
    }
    
    @IBAction func thirdBackgroundButtonTapped(_ sender: Any) {
        delegate.backgroundButtonTapped(index: 2)
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

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
