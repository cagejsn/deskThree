//
//  ViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import UIKit

class deskViewController: UIViewController, UIScrollViewDelegate {

    var workArea: WorkArea = WorkArea()
    let sdhfui: Int = 3
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.addSubview(workArea)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 10)
        workArea.delegate = self
        
    
    }
    
    
    
    
    //MARK: - WorkArea Delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return workArea.background
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    
}

