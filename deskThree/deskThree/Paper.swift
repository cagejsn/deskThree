//
//  Paper.swift
//  deskThree
//
//  Created by Cage Johnson on 10/23/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

class Paper: UIImageView, ImageBlockDelegate {
    
    var images: [ImageBlock]?
    var expressions: [BlockExpression]!
  //  var longPressGR: UILongPressGestureRecognizer!
    
    
        
    //MARK: Initializers
    init() {
        super.init(frame: CGRect(x: 10, y: 10, width: 400, height: 400))
     //   longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(Paper.handleLongPress(sender:)))
   //     longPressGR.minimumPressDuration = 0.8
   //     self.addGestureRecognizer(longPressGR)
        expressions = [BlockExpression]()
        self.image = UIImage(named: "engineeringPaper2")
        self.isOpaque = false
        images = [ImageBlock]() //creates an array to save the imageblocks
    }
    
    //MARK: setup for exporting
    required init(coder unarchiver: NSCoder){
        super.init(coder: unarchiver)!
        images = unarchiver.decodeObject() as! [ImageBlock]!
        expressions = unarchiver.decodeObject() as! [BlockExpression]!
        
    }

    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(images)
        aCoder.encode(expressions)
    }
    
    func savePaper(){

        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as! String
        var filePath = documentsPath.appending("/file.desk")
        NSKeyedArchiver.archiveRootObject(self, toFile: filePath)
    }
    
    func loadPaper(state: Paper){
        

        
    }
    

    //ImageBlock Delegate Functions
    func fixImageToPage(image: ImageBlock){
        
    }
    
    func freeImageForMovement(image: ImageBlock){
        
    }
    
    func helpMove(imageBlock: ImageBlock, dx: CGFloat, dy: CGFloat) {
        imageBlock.frame.origin.x = imageBlock.frame.origin.x + dx
        imageBlock.frame.origin.y = imageBlock.frame.origin.y + dy

    }
    
    // This is never called
    private func setupGestureRecognizers() {
        // 1. Set up a pan gesture recognizer to track where user moves finger
        let panRecognizer = UIPanGestureRecognizer(target: self, action: Selector(("handlePan")))
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        switch sender.state {
        case .began:
            self.startAtPoint(point: point)
        case .changed:
            self.continueAtPoint(point: point)
        case .ended:
            self.endAtPoint(point: point)
        case .failed:
            self.endAtPoint(point: point)
        default:
            assert(false, "State not handled")
        }
    }
    
    
    func drawLine(a: CGPoint, b: CGPoint, buffer: UIImage?) -> UIImage {
        let size = self.bounds.size;
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        self.sendSubview(toBack: self)
        context!.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context!.fill(self.bounds)
        
        // Draw previous buffer first
        if let buffer = buffer {
            buffer.draw(in: self.bounds)
        }
        
        // Draw the line
        self.drawColor.setStroke()
        self.path.lineWidth = self.drawWidth
        self.path.lineCapStyle = CGLineCap.round
        self.path.stroke()
        context!.setLineWidth(self.drawWidth)
        context!.setLineCap(CGLineCap.round)
        
        context!.move(to: a)
        context!.addLine(to: b)
        context!.strokePath()
        
        // Grab the updated buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func startAtPoint(point: CGPoint) {
        self.lastPoint = point
    }
    
    func continueAtPoint(point: CGPoint) {
        autoreleasepool {
            // Draw the current stroke in an accumulated bitmap
            self.buffer = self.drawLine(a: self.lastPoint, b: point, buffer: self.buffer)
            
            // Replace the layer contents with the updated image
            self.image = self.buffer
            
            // Update last point for next stroke
            self.lastPoint = point
        }
    }
    
    func endAtPoint(point: CGPoint) {
        self.lastPoint = CGPoint.zero
    }
    
    var drawColor: UIColor = UIColor.black
    var drawWidth: CGFloat = 10.0
    
    private var path: UIBezierPath = UIBezierPath()
    private var lastPoint: CGPoint = CGPoint.zero
    private var buffer: UIImage = UIImage(named: "engineeringPaper")!

}
