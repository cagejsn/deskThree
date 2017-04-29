//
//  HamburgerMenuViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 4/25/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


protocol HamburgerMenuViewControllerDelegate {
    func fileExplorerButtonTapped()
    func loadImageButtonPushed()
    func printButtonPushed()
    func clearButtonTapped()
    func feedbackButtonTapped()
    func penColorChanged(to: SelectedPenColor)
}

class HamburgerMenuViewController: UIViewController, InsideHamburgerViewDelegate{
    @IBOutlet var scrollView: UIScrollView!
    var insideHamburger: InsideHamburgerView!
    
    var delegate: HamburgerMenuViewControllerDelegate!
    
    
    override func viewDidLoad() {
        insideHamburger = Bundle.main.loadNibNamed("InsideHamburgerView", owner: self, options: nil)?.first as? InsideHamburgerView
        insideHamburger.delegate = self
        scrollView.addSubview(insideHamburger)
        scrollView.delaysContentTouches = false
      //  scrollView.scrollIndicatorInsets
      //  scrollView.showsVerticalScrollIndicator = false
        insideHamburger.setup()
      }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = insideHamburger.bounds.size
    }
    
    func newButtonTapped(){
        if let slideMenuController = slideMenuController() {
            slideMenuController.closeLeft()
            //slideMenuController.mainViewController
        }
    }
    
    func openButtonTapped(){
        slideMenuController()?.closeLeft()
        delegate.fileExplorerButtonTapped()
    }
    
    func printButtonTapped(){
        slideMenuController()?.closeLeft()
        delegate.printButtonPushed()
    }
    
    func penSizeSliderValueChanged(value: Float){
        
    }
    
    func penColorChanged(to: SelectedPenColor){
        delegate.penColorChanged(to: to)
    }
    
    func backgroundButtonTapped(index: Int){
        
    }
    
    func importPhotoButtonTapped(){
        slideMenuController()?.closeLeft()
        delegate.loadImageButtonPushed()
    }
    
    func feedbackButtonTapped() {
        delegate.feedbackButtonTapped()
    }
    
    func clearButtonTapped(){
        delegate.clearButtonTapped()
        
    }
}
