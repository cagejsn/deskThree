//
//  OCRMathView.swift
//  deskThree
//
//  Created by Cage Johnson on 3/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import UIKit
#if !DEBUG
import Mixpanel
#endif


protocol OCRMathViewDelegate {
    func createMathBlock(for mathView: OCRMathView)
    func didRequestWRDisplay(query: String)
    func getViewForTopConstraint(for mathView: OCRMathView) -> UIView
}

class OCRMathView: MAWMathView {
    var clearButton: UIButton!
    var searchWRButton: UIButton!
    var undoButton: UIButton!
    var redoButton: UIButton!
    
    var clearButtonConstraints: [NSLayoutConstraint]!
    var wolframQueryConstraints: [NSLayoutConstraint]!
    var delegate2: OCRMathViewDelegate!
    
    var topBorderLayer: CALayer!
    
    var leftConstraint: NSLayoutConstraint!
    var topContraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!
    
    var isInEditMode: Bool = false
    var targetForEdits: MathBlock!

    #if !DEBUG
    private var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif

    func enterEditModeWith(_ element: MathBlock){
//        self.addSymbols(element.mathSymbols, allowUndo: true)
        if(self.unserialize(element.getData())){
            targetForEdits = element
            isInEditMode = true
            solve()
        }
    }
    
    func endEditMode(){
        targetForEdits = nil
        isInEditMode = false
    }

    func clearButtonTapped(){
        self.clear(false)
    }
    
    func addToPageButtonTapped(){
        delegate2.createMathBlock(for: self)
    }
    
    func undoButtonTapped(){
        self.undo()
    }
    
    func redoButtonTapped(){
        self.redo()
    }
    
    func searchWRButtonTapped(){
        #if !DEBUG
        mixpanel.track(event: "Button: Wolfram Query")
        #endif
        delegate2.didRequestWRDisplay(query: self.resultAsMathML())
    }
    
    func stylize(){
        topBorderLayer = self.addAndReturnTopBorder(color: Constants.DesignColors.deskBlue, width: 5)
        topBorderLayer.opacity = 0.8
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        topBorderLayer.removeFromSuperlayer()
        topBorderLayer = nil
        stylize()
    }
    
    func setupContraintsForClearButton(){
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        let rightConstraint = NSLayoutConstraint(item: clearButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15)
        let topConstraint = NSLayoutConstraint(item: clearButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15)
        let widthConstraint = NSLayoutConstraint(item: clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        let heightConstraint = NSLayoutConstraint(item: clearButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        clearButtonConstraints = [rightConstraint,topConstraint,widthConstraint,heightConstraint]
        self.addConstraints(clearButtonConstraints)

    }
    
    func setupConstraintsForWRQuery(){
        searchWRButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15)
        let bottomConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15)
        let widthConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        let heightConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        wolframQueryConstraints = [leftConstraint,bottomConstraint,widthConstraint,heightConstraint]
        self.addConstraints(wolframQueryConstraints)
        
    }
    
    func setupContraintsForUndoRedo(){
        NSLayoutConstraint.activate([
        
        
        ])
    }
    
    func setupMathViewConstraints(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: 0)
        topContraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: delegate2.getViewForTopConstraint(for: self), attribute: .bottom, multiplier: 1.0, constant: 0)
        heightContraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(mathViewHeight))
        rightConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1.0, constant: 0)
        superview!.addConstraints([leftConstraint,topContraint,heightContraint,rightConstraint])
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Add buttons
        clearButton = UIButton(frame: CGRect())
        clearButton.setImage(UIImage(named:"clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(OCRMathView.clearButtonTapped), for:.touchUpInside)
        self.addSubview(clearButton)
        setupContraintsForClearButton()

        searchWRButton = UIButton(frame: CGRect(x:15, y: 90, width: 50, height: 50))
        searchWRButton.setImage(UIImage(named: "Wolfram-Logo-Blue"), for: .normal)
        searchWRButton.setTitle("wolfram", for: .normal)
        searchWRButton.addTarget(self, action: #selector(OCRMathView.searchWRButtonTapped), for:.touchUpInside)
        searchWRButton.layer.shadowColor = UIColor.black.cgColor
        searchWRButton.layer.shadowOffset = CGSize(width: 1, height: 0)
        searchWRButton.layer.shadowOpacity = 0.7
        searchWRButton.layer.shadowRadius = 1.0
        self.addSubview(searchWRButton)
        setupConstraintsForWRQuery()
        
        undoButton = UIButton(frame: CGRect(x:15, y: 15, width: 50, height: 50))
        undoButton.setImage(#imageLiteral(resourceName: "undoButton"), for: .normal)
        undoButton.contentMode = .scaleAspectFit
        undoButton.addTarget(self, action: #selector(OCRMathView.undoButtonTapped), for: .touchUpInside)
        self.addSubview(undoButton)
        
        redoButton = UIButton(frame: CGRect(x:75, y: 15, width: 50, height: 50))
        redoButton.setImage(#imageLiteral(resourceName: "redoButton"), for: .normal)
        redoButton.contentMode = .scaleAspectFit
        redoButton.addTarget(self, action: #selector(OCRMathView.redoButtonTapped), for: .touchUpInside)
        self.addSubview(redoButton)


        self.clipsToBounds = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
