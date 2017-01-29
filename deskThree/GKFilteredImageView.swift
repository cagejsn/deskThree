//
//  GKFilteredImageView.swift
//  deskThree
//
//  Created by Cage Johnson on 1/28/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


@objc class GKFilteredImageView: GLKView {
    
    var ciContext: CIContext!
    //filters
    var exposureFilter: CIFilter!
    var colorMapFilter: CIFilter!
    var maskToAlphaFilter: CIFilter!
    var colorInvertFilter: CIFilter!
    
    var beginningImage: UIImage!
    var sourceImageOrientation: UIImageOrientation!
    
    
    var output: CIImage!

    
    func outputUIImage() -> UIImage {
        return UIImage()
    }
    
    func setBeginningImage(image:UIImage){
        beginningImage = image
    }
    
    
 @objc func filterImage(for sliderValue:Float){
    
//        print(CACurrentMediaTime())
    
        //set some filter Values
        exposureFilter.setValue(NSNumber(value:sliderValue), forKey: "inputEV")
        output = exposureFilter.outputImage!
//        print("after exposure filter: " + String(CACurrentMediaTime()))
        colorMapFilter.setValue(output, forKey: kCIInputImageKey)
        output = colorMapFilter.outputImage!
    
//        print("after color map: " + String(CACurrentMediaTime()))
        maskToAlphaFilter.setValue(output, forKey: kCIInputImageKey)
        output = maskToAlphaFilter.outputImage!
    
//    print("after mask filter filter: " + String(CACurrentMediaTime()))
        colorInvertFilter.setValue(output, forKey: kCIInputImageKey)
        output = colorInvertFilter.outputImage!
    
   
    }
    
    
    
@objc  func setupFilters(){
    
        var startingImage = CIImage(cgImage: beginningImage.cgImage!)
        sourceImageOrientation = beginningImage.imageOrientation
        
        var gradientImage = CIImage(cgImage: (UIImage(named:"colorMap2")?.cgImage)!)
        
        exposureFilter = CIFilter(name: "CIExposureAdjust")
        exposureFilter.setValue(startingImage, forKey: kCIInputImageKey)

        colorMapFilter = CIFilter(name: "CIColorMap")
        colorMapFilter.setValue(gradientImage, forKey: "inputGradientImage")

        maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha")
        maskToAlphaFilter.setDefaults()
                
        colorInvertFilter = CIFilter(name: "CIColorInvert")
        colorInvertFilter.setDefaults()
        
    }
    
    
    override func draw(_ rect: CGRect) {
     //   glClearColor(0.0, 0.0, 0.0, 0.0)
       // glClear( GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        print("before draw: " + String(CACurrentMediaTime()))
        let scale = CGAffineTransform(scaleX: self.contentScaleFactor, y: self.contentScaleFactor)
        var destRect = CGRect(x: 0, y: 0, width: self.bounds.width  , height: self.bounds.height )
        let drawingRect = rect.applying(scale)
        if(output == nil){
            let firstImg = CIImage(cgImage: beginningImage.cgImage!)
            ciContext.draw(firstImg, in: drawingRect, from: firstImg.extent)
        } else {
            ciContext.draw(output, in: drawingRect, from: output.extent)
        }
        print("after draw: " + String(CACurrentMediaTime()))

    }


    func generateUIImageFromContext() -> UIImage {
        
        if (output == nil){
       return beginningImage
        } else{
        var cgimg = ciContext.createCGImage(output, from: output.extent)
        return UIImage(cgImage: cgimg!)
        }
    }
    
    
   override init(frame: CGRect, context: EAGLContext){
        super.init(frame: frame, context: context)
    
        EAGLContext.setCurrent(context)
        ciContext = CIContext(eaglContext: context)
    
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
