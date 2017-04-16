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
    func didRequestWRDisplay(query: String)
}

class OCRMathView: MAWMathView {
    var clearButton: UIButton!
    var searchWRButton: UIButton!
    var outputAreaForExpressions: UIButton!
    var outputAreaConstraints: [NSLayoutConstraint]!
    var delegate2: OCRMathViewDelegate!
    
    func clearButtonTapped(){
        self.clear(false)
    }
    
    func addToPageButtonTapped(){
        delegate2.createMathBlock()
    }
    
    func searchWRButtonTapped(){
        delegate2.didRequestWRDisplay(query: self.resultAsText())
    }
    
    func setupContraintsForOutputArea(){
        outputAreaForExpressions.translatesAutoresizingMaskIntoConstraints = false
        
        let rightConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15)
        let topConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15)
        let widthConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        let heightConstraint = NSLayoutConstraint(item: outputAreaForExpressions, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
        outputAreaConstraints = [rightConstraint,topConstraint,widthConstraint,heightConstraint]
        self.addConstraints(outputAreaConstraints)

    }
    
 
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        //add buttons
        clearButton = UIButton(frame: CGRect(x: 15, y: 15, width: 50, height: 50))
        clearButton.setImage(UIImage(named:"clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(OCRMathView.clearButtonTapped), for:.touchUpInside)
        self.addSubview(clearButton)

        
        searchWRButton = UIButton(frame: CGRect(x: 15, y: 75, width: 50, height: 50))
        searchWRButton.setImage(UIImage(named:"clear"), for: .normal)
        searchWRButton.addTarget(self, action: #selector(OCRMathView.searchWRButtonTapped), for:.touchUpInside)
        self.addSubview(searchWRButton)

        self.clipsToBounds = false
        outputAreaForExpressions = UIButton(frame: CGRect(x: self.frame.width - 65, y: 15, width: 50, height: 50))
        outputAreaForExpressions.setImage(UIImage(named:"addToPage"), for: .normal)
        outputAreaForExpressions.contentMode = .scaleAspectFit
        self.addSubview(outputAreaForExpressions)
        setupContraintsForOutputArea()
        outputAreaForExpressions.addTarget(self, action: #selector(OCRMathView.addToPageButtonTapped), for: .touchUpInside)
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
}
