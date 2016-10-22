//
//  ViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import UIKit

class deskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate{

    var workArea: WorkArea = WorkArea()
    var singleTouchPanGestureRecognizer: UIPanGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        
        
        singleTouchPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(deskViewController.handleSinglePan))
        
        self.view.addSubview(workArea)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
        workArea.delegate = self
        
        workArea.minimumZoomScale = 0.1
        workArea.maximumZoomScale = 2.0
        
        singleTouchPanGestureRecognizer.minimumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(singleTouchPanGestureRecognizer)
        singleTouchPanGestureRecognizer.isEnabled = true
        singleTouchPanGestureRecognizer.delegate = self
        
    }
    
    
    
    func handleSinglePan(sender: UIPanGestureRecognizer) {
       // self.view.backgroundColor = UIColor.green
      //  self.workArea.isHidden = true
    
    }
    
    
    //MARK: - WorkArea Delegate
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {

    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workArea.background

    }
    
    
    /*
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return workArea.background
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    
}

