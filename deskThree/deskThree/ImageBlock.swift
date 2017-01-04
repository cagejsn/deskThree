//
//  ImageBlock.swift
//  deskThree
//
//  Created by Cage Johnson on 10/22/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

protocol ImageBlockDelegate {
    func fixImageToPage(image: ImageBlock)
    func freeImageForMovement(image: ImageBlock)
}

class ImageBlock: UIImageView, UIGestureRecognizerDelegate {
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer?
    var zoomGR: UIPinchGestureRecognizer?
    var editable: Bool = false
    var delegate: ImageBlockDelegate! = nil
    var orientationInt: Int = 0

    //MARK: Custom Methods
    func toggleEditable(){
        if(!editable){
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.purple.cgColor
            zoomGR?.isEnabled = true
            editable = true
            delegate!.freeImageForMovement(image: self)
            isUserInteractionEnabled = true
            
        } else{
            self.layer.borderColor = UIColor.clear.cgColor
            editable = false
            delegate!.fixImageToPage(image: self)
            zoomGR?.isEnabled = false
            isUserInteractionEnabled = false
        }
    }
    
    // MARK: touch handlers
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(editable){
            superview!.bringSubview(toFront: self)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(editable){
            let touch: AnyObject = touches.first as UITouch!
            let currentTouch = touch.location(in: self)
            let previousTouch = touch.previousLocation(in: self)
            let dx = currentTouch.x - previousTouch.x
            let dy = currentTouch.y - previousTouch.y
            self.frame = self.frame.offsetBy(dx: dx, dy: dy)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
 
    func handleDoubleTap( sender: UITapGestureRecognizer) {
        toggleEditable()
    }
    
    func handlePinch( sender: UIPinchGestureRecognizer){
        
        if(editable){
            if (sender.state == UIGestureRecognizerState.changed) {
                
                if(sender.velocity < 0){
                    self.transform = self.transform.scaledBy(x: 0.99 , y: 0.99)
                } else {
                    self.transform = self.transform.scaledBy(x: 1.01 , y: 1.01)
                }
            }
        }
    }
    //would be nice to have a freeform rotation rather than 90 degree increments, but that can wait
    func rotateImage( sender: UITapGestureRecognizer){
        var newOrienation: UIImageOrientation!
        switch orientationInt {
        case 1:
            newOrienation = UIImageOrientation.right
            orientationInt = 2
        case 2:
            newOrienation = UIImageOrientation.down
            orientationInt = 3
        case 3:
            newOrienation = UIImageOrientation.left
            orientationInt = 4
        default:
            newOrienation = UIImageOrientation.up
            orientationInt = 1
        }
        image = UIImage(cgImage: (image?.cgImage)!, scale: (image?.scale)!, orientation: newOrienation)
    }
    
    //processes the UIImagePicker's image before setting it to self's .image property
    //Uses iOS built in filters to map dark colors to black and light to transparent
    func editAndSetImage(image toEdit: UIImage){
        self.image = toEdit
        /*
        var editedImage = image

        //going to make a custom CIFilter
        //change the input image to a CIImage
        var context = CIContext(options: nil)
        
        //this is going to make the black areas transparent
        
        if var currentFilter = CIFilter(name: "CIColorInvert"){
        let beginImage = CIImage(image: toEdit)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            if var output = currentFilter.outputImage {
                let cgimg = context.createCGImage(output, from: output.extent)
                
                let editedImage = UIImage(cgImage: cgimg!)
                // do something interesting with the processed image
                
                self.image = editedImage
                
            }
        }
        */
        /*
        if var currentFilter = CIFilter(name: "CIExposureAdjust") {
            
            let beginImage = CIImage(image: toEdit)
            let gradientImage = CIImage(image: UIImage(named: "colorMap2")!, options: nil)
            
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter.setValue(1.3, forKey: "inputEV")
           
            
            if var output = currentFilter.outputImage {

                currentFilter = CIFilter(name: "CIColorMap")!
                currentFilter.setValue(output, forKey: kCIInputImageKey)
                currentFilter.setValue(gradientImage, forKey: "inputGradientImage")
                output = currentFilter.outputImage!
                
                currentFilter = CIFilter(name: "CIMaskToAlpha")!
                currentFilter.setValue(output, forKey: kCIInputImageKey)
                currentFilter.setDefaults()
                output = currentFilter.outputImage!
                
                currentFilter = CIFilter(name: "CIColorInvert")!
                currentFilter.setValue(output, forKey: kCIInputImageKey)
                currentFilter.setDefaults()
                output = currentFilter.outputImage!
                
                let cgimg = context.createCGImage(output, from: output.extent)
                
                let editedImage = UIImage(cgImage: cgimg!)
                // do something interesting with the processed image
 
                self.image = editedImage
            }

        }
  */
    }

    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageBlock.rotateImage))
        doubleTapGestureRecognizer!.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delegate = self
        self.addGestureRecognizer(doubleTapGestureRecognizer!)
        
        zoomGR = UIPinchGestureRecognizer(target: self, action: #selector(ImageBlock.handlePinch))
        zoomGR!.delegate = self
        self.addGestureRecognizer(zoomGR!)
        
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.purple.cgColor
        editable = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
