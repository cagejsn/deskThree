//
//  OCRMathView.swift
//  deskThree
//
//  Created by Cage Johnson on 3/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import UIKit

protocol OCRMathViewDelegate {
    func createMathBlock()
}

class OCRMathView: MAWMathView {
    var clearButton: UIButton
    var outputAreaForExpressions: UIButton!
    var outputAreaConstraints: [NSLayoutConstraint]!
    var delegate2: OCRMathViewDelegate!
    
    func clearButtonTapped(){
        self.clear(false)
    }
    
    func addToPageButtonTapped(){
        delegate2.createMathBlock()
    }
    
    func setupContraintsForOutputArea(){
        outputAreaForExpressions.translatesAutoresizingMaskIntoConstraints = false
        
        let rightConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15)
        let topConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15)
        // var topConstraint = NSLayoutConstraint(item: mathView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 100)
        let widthConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        let heightConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        outputAreaConstraints = [rightConstraint,topConstraint,widthConstraint,heightConstraint]
        self.addConstraints(outputAreaConstraints)

    }
    
 
    
    
    override init(frame: CGRect) {
        //add buttons
        clearButton = UIButton(frame: CGRect(x: 15, y: 15, width: 50, height: 50))
        clearButton.setImage(UIImage(named:"clear"), for: .normal)
        super.init(frame: frame)
        clearButton.addTarget(self, action: #selector(OCRMathView.clearButtonTapped), for:.touchUpInside)

        self.addSubview(clearButton)
        self.clipsToBounds = false
        outputAreaForExpressions = UIButton(frame: CGRect(x: self.frame.width - 65, y: 15, width: 50, height: 50))
        outputAreaForExpressions.setImage(UIImage(named:"addToPage"), for: .normal)
      //  outputAreaForExpressions.layer.borderColor = UIColor.purple.cgColor
     //   outputAreaForExpressions.layer.cornerRadius = 10
     //   outputAreaForExpressions.layer.borderWidth = 2
        outputAreaForExpressions.contentMode = .scaleAspectFit
        self.addSubview(outputAreaForExpressions)
        setupContraintsForOutputArea()
        outputAreaForExpressions.addTarget(self, action: #selector(OCRMathView.addToPageButtonTapped), for: .touchUpInside)
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
}
