//
//  DeskViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//
import UIKit

class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, GKImagePickerDelegate {

   // let imagePicker = UIImagePickerController()
    let gkimagePicker = GKImagePicker()
    @IBOutlet var workArea: WorkArea!
    var singleTouchPanGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        workArea.delegate = self
        self.view.sendSubview(toBack: workArea)
        workArea.minimumZoomScale = 0.3
        workArea.maximumZoomScale = 2.0
        
        
        gkimagePicker.delegate = self
        gkimagePicker.cropSize = CGSize(width: 320, height: 90)
        gkimagePicker.resizeableCropArea = true
        

        
        /*
        workArea = WorkArea()
        self.view.addSubview(workArea)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
        
        workArea.minimumZoomScale = 0.1
        workArea.maximumZoomScale = 2.0
        */
        // setting up the GR that will handle drawing w finger & stylus
        singleTouchPanGestureRecognizer = UIPanGestureRecognizer(target: workArea.currentPage, action: #selector(Paper.handlePan))
        singleTouchPanGestureRecognizer.minimumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.maximumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.isEnabled = true
        singleTouchPanGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(singleTouchPanGestureRecognizer)
 
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
 
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    //function to handle the drawing (is in paper.swift)
    func handleSinglePan(sender: UIPanGestureRecognizer) {
        // workArea.currentPage.handlePan(sender: sender)
        // self.view.backgroundColor = UIColor.green
      //  self.workArea.isHidden = true
    }
    
    //MARK: - WorkArea Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return workArea.currentPage
    }
    
    //MARK: UIToolbar on click methods
    @IBAction func printButtonPushed(_ sender: UIBarButtonItem) {
        workArea.frame = workArea.currentPage.frame
        var pdfFileName = PDFGenerator.createPdfFromView(aView: workArea, saveToDocumentsWithFileName: "secondPDF")
        var pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
        pdfShareHelper.delegate = self
        pdfShareHelper.uti = "com.adobe.pdf"
        // Currently, Preview itself gives option to share
        pdfShareHelper.presentPreview(animated: false)
        //pdfShareHelper.presentOptionsMenu(from: self.workArea.frame, in: self.workArea, animated: false)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
    }
    @IBAction func loadImageButtonPushed(_ sender: UIBarButtonItem) {
        
        present(gkimagePicker.imagePickerController, animated: true, completion: nil)
        
        /*
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .currentContext
        present(imagePicker, animated: true, completion: nil)
    */
    }
    
    
    
    
    // MARK: UIImagePickerController Delegate
    

@objc func imagePicker(_ imagePicker: GKImagePicker,  pickedImage: UIImage) {
        
        
        if let pickedImage = pickedImage as? UIImage  {
            var imageBlock: ImageBlock = ImageBlock(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            workArea.currentPage.addSubview(imageBlock)
            imageBlock.center = self.view.center
            imageBlock.isUserInteractionEnabled = true
            imageBlock.contentMode = .scaleAspectFit
            imageBlock.editAndSetImage(image: pickedImage)
            //imageBlock.image = pickedImage
            imageBlock.delegate = self.workArea.currentPage
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

