//
//  Clipper.swift
//  LassoForMath
//
//  Created by Cage Johnson on 11/2/17.
//  Copyright © 2017 Cage Johnson. All rights reserved.
//

import Foundation
import UIKit

typealias VoidBlock = ()->()

protocol ClipperDelegate: class {
    func end()
}

class Clipper: UIView {
    
    var activePath: UIBezierPath!
    var animatedClippingLayer: CAShapeLayer = CAShapeLayer()
    let pattern: [NSNumber] = [NSNumber(value:5.0),NSNumber(value:5.0)]
    weak var handleClips: HandleClips?
    var hasFinishedSelection: Bool = false
    weak var delegate: ClipperDelegate!
    
    //responder chain overrides
    override var canBecomeFirstResponder: Bool {
        get {
           return true
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(Clipper.resignFirstResponder), name: NSNotification.Name.UIMenuControllerDidHideMenu , object: nil)
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIMenuControllerDidHideMenu, object: nil)
        delegate.end()
        return super.resignFirstResponder()
    }
    
        
    //clipper should work as follows:
    // the initialization of the clipper happens after a button is pushed on the VC
    // the clipper is initialized (it's a view) with the same size as a view which it is layered on top of. It should steal any touch input from that view as it makes a selection.
    
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
    
    func beginSelection(with point: CGPoint){
        if(!hasFinishedSelection){
            setupPaths()
            activePath.move(to: point)
        }
    }
    
    func incrementSelection(withNew point: CGPoint){
        if(!hasFinishedSelection){
            activePath.addLine(to: point)
            animatedClippingLayer.path = activePath.cgPath
        }
    }
    
    func endSelection(forLastTouch point: CGPoint){
        if(!hasFinishedSelection){
            activePath.close()
            animatedClippingLayer.path = activePath.cgPath
            hasFinishedSelection = true
            showSelectableOptions(forRect: activePath.bounds)
        }
    }
  
    func showSelectableOptions(forRect: CGRect){
        
        self.becomeFirstResponder()
        var selectActionMenu: UIMenuController = UIMenuController.shared
        selectActionMenu.arrowDirection = .down
        selectActionMenu.setTargetRect(forRect, in: self)
        var selectableActionMath = UIMenuItem(title: "math", action: #selector(mathButtonTapped))
        var selectableActionClear = UIMenuItem(title: "clear", action: #selector(clearButtonTapped))
        var selectableActionCancel = UIMenuItem(title: "cancel", action: #selector(cancelButtonTapped))
        selectActionMenu.menuItems = [selectableActionMath,selectableActionClear,selectableActionCancel]
        selectActionMenu.setMenuVisible(true, animated: true)
    }
    
    func mathButtonTapped(){
        handleClips?.handleMath(selection: self.activePath.cgPath)
    }
    
    func clearButtonTapped(){
        handleClips?.handleClear(selection: self.activePath.cgPath)
    }
    
    func cancelButtonTapped(){
        handleClips?.handleCancel()
    }
    
    
    func setupPaths(){
        activePath = UIBezierPath()
        animatedClippingLayer =
            {()->CAShapeLayer in
                var anmLayer = CAShapeLayer()
                anmLayer.fillColor = UIColor.clear.cgColor
                anmLayer.strokeColor = UIColor.black.cgColor
                anmLayer.lineWidth = 1
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
    
    
    init(overSubview view: UIView){
        //how to handle constraints and the ability to rotate?
        super.init(frame:CGRect(x: 0, y: 0, width: 1275, height: 1650))
        //self.transform = view.transform
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
