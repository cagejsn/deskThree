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
    func penColorButtonTapped(index: Int)
    func backgroundButtonTapped(index: Int)
    func importPhotoButtonTapped()
    func clearButtonTapped()

}


class InsideHamburgerView: UIView {
    
    var delegate: InsideHamburgerViewDelegate!
    
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
        delegate.penColorButtonTapped(index: 0)
    }
    
    @IBAction func secondColorButtonTapped(_ sender: Any) {
        delegate.penColorButtonTapped(index: 1)
    }
    
    @IBAction func thirdColorButtonTapped(_ sender: Any) {
        delegate.penColorButtonTapped(index: 2)
    }
    
    @IBAction func fourthColorButtonTapped(_ sender: Any) {
        delegate.penColorButtonTapped(index: 3)
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
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        delegate.clearButtonTapped()    
    }
    
    
    
}
