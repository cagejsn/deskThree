//
//  DeskViewController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//
import UIKit

class DeskViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIDocumentInteractionControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    @IBOutlet var workArea: WorkArea!
    var singleTouchPanGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        workArea.delegate = self
        self.view.sendSubview(toBack: workArea)
        workArea.minimumZoomScale = 0.3
        workArea.maximumZoomScale = 2.0
        
        
        imagePicker.delegate = self
        /*
        workArea = WorkArea()
        self.view.addSubview(workArea)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
        
        workArea.minimumZoomScale = 0.1
        workArea.maximumZoomScale = 2.0
        // setting up the GR that will handle drawing w finger & stylus
        singleTouchPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DeskViewController.handleSinglePan))
        singleTouchPanGestureRecognizer.minimumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.maximumNumberOfTouches = 1
        singleTouchPanGestureRecognizer.isEnabled = true
        singleTouchPanGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(singleTouchPanGestureRecognizer)
        */
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
        return workArea.currentPage
    }
    
    //MARK: UIToolbar on click methods
    
    @IBAction func printButtonPushed(_ sender: UIBarButtonItem) {
        workArea.frame = workArea.currentPage.frame
        var pdfFileName = PDFGenerator.createPdfFromView(aView: workArea, saveToDocumentsWithFileName: "secondPDF")
        var pdfShareHelper:UIDocumentInteractionController = UIDocumentInteractionController(url:URL(fileURLWithPath: pdfFileName))
        pdfShareHelper.delegate = self
        pdfShareHelper.uti = "com.adobe.pdf"
        pdfShareHelper.presentPreview(animated: false)
        //pdfShareHelper.presentOptionsMenu(from: self.workArea.frame, in: self.workArea, animated: false)
        workArea.boundInsideBy(superView: self.view, x1: 10, x2: 10, y1: 10, y2: 44)
    }
    @IBAction func loadImageButtonPushed(_ sender: UIBarButtonItem) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .currentContext
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            var imageBlock: ImageBlock = ImageBlock(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            workArea.currentPage.addSubview(imageBlock)
            imageBlock.center = self.view.center
            imageBlock.isUserInteractionEnabled = true
            imageBlock.contentMode = .scaleAspectFit
            imageBlock.editAndSetImage(image: pickedImage)
            //imageBlock.image = pickedImage
            imageBlock.delegate = self.workArea.currentPage
        }
        /*
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            var imageBlock: ImageBlock = ImageBlock(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
            workArea.currentPage.addSubview(imageBlock)
            imageBlock.center = self.view.center
            imageBlock.isUserInteractionEnabled = true
            imageBlock.contentMode = .scaleAspectFit
            //imageBlock.image = editImage(pickedImage)
            imageBlock.image = pickedImage
            imageBlock.delegate = self.workArea.currentPage
        }
    */
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

