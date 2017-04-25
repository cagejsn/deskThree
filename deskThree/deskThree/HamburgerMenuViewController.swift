//
//  HamburgerMenuViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 4/25/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class HamburgerMenuViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    
    var insideHamburgerView: InsideHamburgerView!
    
    
    override func viewDidLoad() {
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 1
        insideHamburgerView = Bundle.main.loadNibNamed("InsideHamburgerView", owner: self, options: nil)?.first as? InsideHamburgerView
        scrollView.addSubview(insideHamburgerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentSize = insideHamburgerView.bounds.size
    }
    
}
