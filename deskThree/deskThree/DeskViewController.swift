//
//  ViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//
import UIKit

class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate{

    var workArea: WorkArea!
    var singleTouchPanGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        workArea = WorkArea()
        self.view.addSubview(workArea)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
        workArea.delegate = self
        workArea.minimumZoomScale = 0.1
        workArea.maximumZoomScale = 2.0
        // setting up the GR that will handle drawing w finger & stylus
        singleTouchPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DeskViewController.handleSinglePan))
        singleTouchPanGestureRecognizer.minimumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.maximumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.isEnabled = true
        singleTouchPanGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(singleTouchPanGestureRecognizer)
    }
    /*
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        /*
        workArea.frame = workArea.background.frame
        var pdfFileName = PDFGenerator.createPdfFromView(aView: workArea, saveToDocumentsWithFileName: "secondPDF")
        var pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
        pdfShareHelper.delegate = self
        pdfShareHelper.uti = "com.adobe.pdf"
         // pdfShareHelper.presentPreview(animated: false)
        //pdfShareHelper.presentOptionsMenu(from: self.workArea.frame, in: self.workArea, animated: false)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
 */
    }
 */
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    //function to handle the drawing
    func handleSinglePan(sender: UIPanGestureRecognizer) {
       // self.view.backgroundColor = UIColor.green
      //  self.workArea.isHidden = true
    }
    
    //MARK: - WorkArea Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workArea.background
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

