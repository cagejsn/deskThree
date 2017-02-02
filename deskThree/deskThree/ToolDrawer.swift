//
//  ToolDrawer.swift
//  deskThree
//
//  Created by Cage Johnson on 1/31/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

let toolSelectorHeight = 100
let toolDrawerWidth = 40


class ToolDrawer: UIView {
    
    var allPad: AllPad!
    
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var isActive: Bool = false
    var previousTranslation: CGFloat = 0
    
    
    var rightConstaint: NSLayoutConstraint!
    var bottomContraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!
    var widthContraint: NSLayoutConstraint!
    
    func handlePan(sender: UIPanGestureRecognizer){
        let touch = sender.location(in: self)
        let selector = Int(touch.y) / toolSelectorHeight
        let currentTranslation = sender.translation(in: self).x
        
        if(sender.state == .began){
            
        }
        
        var dx: CGFloat = 0
        if (sender.state == .changed){
            dx = currentTranslation - previousTranslation
            previousTranslation = currentTranslation
        }
        
        if(self.frame.width - dx >= 40){
        self.frame.origin.x += (dx/2)
        self.frame = self.frame.insetBy(dx: (dx/2), dy: 0)
        }
        
        print(String(describing:self.frame) + " but " + String(describing:UIScreen.main.bounds))
        

        
        if (!isActive){
            
            switch (selector) {
                
            case 0:
                allPad = AllPad(frame: CGRect(x: CGFloat(toolDrawerWidth), y: 0, width: Constants.dimensions.AllPad.width, height: Constants.dimensions.AllPad.height))
                addSubview(allPad)
                isActive = true
                break
            case 1:
                break
            default:
                break
            }
            
        } else {
            
            
            
        }
        
        if(sender.state == .ended){
            previousTranslation = 0
            
            superview?.removeConstraint(widthContraint)
            widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.frame.width)
            superview!.addConstraint(widthContraint)
            
            
            for i in superview!.constraints {
               
                    print(i)
                
            }
        }
    }
    
    
    
    
    func setupConstraints(){
        self.translatesAutoresizingMaskIntoConstraints = false
        rightConstaint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1.0, constant: 0)
        bottomContraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1.0, constant: -44)
        heightContraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 731)
        widthContraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        superview!.addConstraints([rightConstaint,bottomContraint,heightContraint,widthContraint])
    }
    
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 40, height: 731))
        self.backgroundColor = UIColor.gray
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
        var lastHeight = 0
        for height in stride(from: 0, to: Int(self.frame.height), by: toolSelectorHeight) {
            print(height)
            var imageView = UIImageView(frame: CGRect(x: 0, y: lastHeight, width: toolDrawerWidth, height: height - lastHeight))
            lastHeight = height
            imageView.image = UIImage(named:"apple")
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            
        }
        
        
        
    }
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.gray
    
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
        var lastHeight = 0
        for height in stride(from: 0, to: Int(self.frame.height), by: toolSelectorHeight) {
            print(height)
            var imageView = UIImageView(frame: CGRect(x: 0, y: lastHeight, width: toolDrawerWidth, height: height - lastHeight))
            lastHeight = height
            imageView.image = UIImage(named:"apple")
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            
        }
    

    
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        self.addGestureRecognizer(panGestureRecognizer)
        var lastHeight = 0
        for height in stride(from: 0, to: Int(self.frame.height), by: toolSelectorHeight) {
            print(height)
            var imageView = UIImageView(frame: CGRect(x: 0, y: lastHeight, width: toolDrawerWidth, height: height - lastHeight))
            lastHeight = height
            imageView.image = UIImage(named:"apple")
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            
        }
        
        
    }
    
}
