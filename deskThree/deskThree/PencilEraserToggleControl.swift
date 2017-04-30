//
//  pencilEraserToggleControl.swift
//  deskThree
//
//  Created by Cage Johnson on 4/27/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


enum SelectedWritingInstrument {
    case pencil
    case eraser
}

protocol PencilEraserToggleControlDelegate {
    func switchTo(_ selected: SelectedWritingInstrument)
}

class PencilEraserToggleControl: UIImageView {
    
    var pencilView: UIImageView!
    var eraserView: UIImageView!
    
    var singleTapGR: UITapGestureRecognizer!
    var panGR: UIPanGestureRecognizer!
    
    var previousTranslation: CGFloat = 0
    var selected: SelectedWritingInstrument = .pencil
    
    var delegate: PencilEraserToggleControlDelegate!
   
    
    func handleSingleTap(_ sender: UITapGestureRecognizer ){
        
        let loc = sender.location(in: self)
        
        if(loc.x <= (self.frame.width/2)){
            if(selected == .pencil){
                return
            } else {
                toggleWritingInstrument()
            }
        }
        
        if(loc.x > (self.frame.width/2)){
            if(selected == .eraser){
                return
            } else {
                toggleWritingInstrument()
            }
        }
    }
    
    
    
    func handlePan(_ sender: UIPanGestureRecognizer){
      let loc = sender.location(in: self)
        
        if(loc.x <= (self.frame.width/2)){
            if(selected == .pencil){
                return
            } else {
                toggleWritingInstrument()
            }
        }
        
        if(loc.x > (self.frame.width/2)){
            if(selected == .eraser){
                return
            } else {
                toggleWritingInstrument()
            }
        }
        
    }
    
    
    func toggleWritingInstrument(){
        if(selected == .pencil){
            selected = .eraser
            self.image = UIImage(named: "eraserSelected")
        } else {
            selected = .pencil
            self.image = UIImage(named: "pencilSelected")
        }
        delegate.switchTo(selected)
    }
    
    func setupConstraintsForPencilAndEraser(){
        let margins = self.layoutMarginsGuide
        pencilView.translatesAutoresizingMaskIntoConstraints = false
        eraserView.translatesAutoresizingMaskIntoConstraints = false
        pencilView.widthAnchor.constraint(equalTo: eraserView.widthAnchor).isActive = true
        pencilView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 5).isActive = true        
        pencilView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        pencilView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        pencilView.rightAnchor.constraint(equalTo: eraserView.leftAnchor, constant: -15).isActive = true
        eraserView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -5).isActive = true
        eraserView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        eraserView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = UIImage(named: "pencilSelected")
        
        self.layer.borderColor = UIColor.init(colorLiteralRed: 0, green: 191/255, blue: 1.0, alpha: 1.0).cgColor
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 3
        
        self.isUserInteractionEnabled = true
        
        pencilView = UIImageView(image: UIImage(named: "cartoonPencil"))
        pencilView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        eraserView = UIImageView(image: UIImage(named: "cartoonEraser"))
        eraserView.frame = CGRect(x: 50, y: 0, width: 50, height: 50)

        pencilView.contentMode = .scaleAspectFit
        eraserView.contentMode = .scaleAspectFit
        self.addSubview(pencilView)
        self.addSubview(eraserView)
        
        setupConstraintsForPencilAndEraser()
        
        singleTapGR = UITapGestureRecognizer(target: self, action: #selector(PencilEraserToggleControl.handleSingleTap(_:)))
        singleTapGR.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGR)
        panGR = UIPanGestureRecognizer(target: self, action: #selector(PencilEraserToggleControl.handlePan(_:)))
        panGR.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGR)

     
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
