//
//  Clipper.swift
//  LassoForMath
//
//  Created by Cage Johnson on 11/2/17.
//  Copyright © 2017 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

typealias AcceptsArgCompletionBlock = (CGPath)->()


class Clipper: UIView {
    
    var completionBlock: AcceptsArgCompletionBlock!
    var activePath: UIBezierPath!
    var animatedClippingLayer: CAShapeLayer = CAShapeLayer()
    let pattern: [NSNumber] = [NSNumber(value:5.0),NSNumber(value:5.0)]
    var viewToClipFrom: UIView!
    
    //clipper should work as follows:
    // the initialization of the clipper happens after a button is pushed on the VC
    // the clipper is initialized (it's a view) with the same size as a view which it is layered on top of. It should steal any touch input from that view as it makes a selection.
    // upon finishing a path, the Clipper will use pointers that it was initialized with and
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event )
        let point = touches.first?.location(in: self)
        beginSelection(with:point!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let point = touches.first?.location(in: self)
        incrementSelection(withNew: point!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event )
        let point = touches.first?.location(in: self)
        endSelection(forLastTouch:point!)
    }
    
   
    func setCompletionFunction(functionToCall: @escaping (CGPath)->()){
        completionBlock = functionToCall
    }
    
    
    func beginSelection(with point: CGPoint){
        setupPaths()
        activePath.move(to: point)
        
    }
    
    func incrementSelection(withNew point: CGPoint){
        activePath.addLine(to: point)
        animatedClippingLayer.path = activePath.cgPath
    }
    
    
    func endSelection(forLastTouch point: CGPoint){
        activePath.close()
        animatedClippingLayer.path = activePath.cgPath
        //performClipping()
        //completionBlock(activePath.cgPath)
        showSelectableOptions()     
    }
    
    func setupPaths(){
        activePath = UIBezierPath()
        animatedClippingLayer =
            {()->CAShapeLayer in
                var anmLayer = CAShapeLayer()
                anmLayer.fillColor = UIColor.clear.cgColor
                anmLayer.strokeColor = UIColor.black.cgColor
                anmLayer.lineWidth = 2
                anmLayer.lineDashPattern = pattern
                return anmLayer
        }()
        
        var marchingAntsAnimation = {()->CABasicAnimation in
            var anm = CABasicAnimation(keyPath: "lineDashPhase")
            anm.duration = 0.25
            anm.fromValue = NSNumber(value: 0.0)
            anm.toValue = NSNumber(value: 10.0)
            anm.repeatCount = .infinity
            return anm
        }()
        animatedClippingLayer.add(marchingAntsAnimation, forKey: "marchingTheAnts")
        self.layer.addSublayer(animatedClippingLayer)
    }
    
    func showSelectableOptions(){
        
        var selectableTypePicker: UIToolbar
        var optionsViewWidth: CGFloat = 140
        
        let x = activePath.bounds.origin.x + ((activePath.bounds.width - optionsViewWidth)/2)
        
        selectableTypePicker = UIToolbar(frame: CGRect(x: x, y: activePath.bounds.origin.y - 45, width: optionsViewWidth, height: 40))
        selectableTypePicker.backgroundColor = UIColor.green
        self.addSubview(selectableTypePicker)
        var mathButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil)
       // selectableTypePicker.addSubview(mathButton)
        var imgButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
        var wordsButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(wordsButtonTapped))
        
        

        
        selectableTypePicker.items = [mathButton, imgButton, wordsButton]
        
    }
    
    func wordsButtonTapped(){
        
        let cartesianDifference = activePath.cgPath.boundingBox.origin - self.convert(activePath.cgPath.boundingBox, to: superview).origin
        let scaleDifference = activePath.cgPath.boundingBox.width / self.convert(activePath.cgPath.boundingBox, to: superview).width
        
        //activePath.apply(CGAffineTransform.init(translationX: cartesianDifference.x, y: cartesianDifference.y))
        //activePath.apply(CGAffineTransform.init(scaleX: scaleDifference, y: scaleDifference))
        
       print(self.frame)
        completionBlock(activePath.cgPath)
       // print(frame)
       self.removeFromSuperview()
    }
    
    
    func performClipping(){
        
        var result = UIImageView()
       /*
        switch(clipperType) {
        case .imageView:
            
            break
        case .jotView:
            break
        case .pdfContext:
            break
        case .context:
            var maskLayer = CAShapeLayer()
            maskLayer.path = activePath.cgPath
            UIGraphicsBeginImageContextWithOptions(activePath.bounds.size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()
            var clippedRect = CGRect(x: 0,y:0, width: activePath.bounds.size.width, height: activePath.bounds.size.height)
            var drawRect = CGRect(x: activePath.bounds.origin.x * -1, y: activePath.bounds.origin.y * -1, width: viewToClipFrom.frame.width , height: viewToClipFrom.frame.height)
            viewToClipFrom.layer.mask = maskLayer
            context?.translateBy(x: drawRect.origin.x, y: drawRect.origin.y)
            viewToClipFrom.layer.render(in: context!)
            viewToClipFrom.layer.mask = nil
            var img = context?.makeImage()
            result = UIImageView(frame: activePath.bounds )
            result.image = UIImage(cgImage:img!)
            break
            
        default:
            break
        }
        */
       // completionBlock(result)
    }
    
    func attemptToConstraint(withView view: UIView){
        if let superView = view.superview {
            superView.addSubview(self)
            superview?.addConstraints(
                { () -> [NSLayoutConstraint] in
                    var contraints = [NSLayoutConstraint]()
                    self.layoutMarginsGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
                    self.layoutMarginsGuide.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
                    self.layoutMarginsGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                    self.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                    return constraints
                }()
            )
        }
    }
    
    init(overSubview view: UIView){
        //how to handle constraints and the ability to rotate?
        print(view.bounds)
        print(view.frame)
        
        super.init(frame:CGRect(x: 0, y: 0, width: 1275, height: 1650))
        //self.transform = view.transform
        viewToClipFrom = view
        //attemptToConstraint(withView:view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
