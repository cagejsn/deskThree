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
    
    
    override func viewDidLoad() {
        var imageView = UIImageView(image: UIImage(named: "apple"))
        
        
        //scrollView.delegate = self
        scrollView.addSubview(imageView)
    }
    
    
    
    
    
}
