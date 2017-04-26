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
}

class OCRMathView: MAWMathView {
    var clearButton: UIButton!
    var searchWRButton: UIButton!
    var outputAreaForExpressions: UIButton!
    var outputAreaConstraints: [NSLayoutConstraint]!
    var wolframQueryConstraints: [NSLayoutConstraint]!
    var delegate2: OCRMathViewDelegate!

    #if !DEBUG
    private var mixpanel = Mixpanel.initialize(token: "4282546d172f753049abf29de8f64523")
    #endif

    
    func clearButtonTapped(){
        self.clear(false)
    }
    
    func addToPageButtonTapped(){
        delegate2.createMathBlock(for: self)
    }
    
    func searchWRButtonTapped(){
        #if !DEBUG
        mixpanel.track(event: "Button: Wolfram Query")
        #endif

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
    
    func setupConstraintsForWRQuery(){
        searchWRButton.translatesAutoresizingMaskIntoConstraints = false
        
        let leftConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 10)
        let bottomConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -10)
        let widthConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90)
        let heightConstraint = NSLayoutConstraint(item: searchWRButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        wolframQueryConstraints = [leftConstraint,bottomConstraint,widthConstraint,heightConstraint]
        self.addConstraints(wolframQueryConstraints)
        
    }
    
 
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        //add buttons
        clearButton = UIButton(frame: CGRect(x: 15, y: 15, width: 50, height: 50))
        clearButton.setImage(UIImage(named:"clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(OCRMathView.clearButtonTapped), for:.touchUpInside)
        self.addSubview(clearButton)

        
      //  searchWRButton = UIButton(frame: )
        searchWRButton = UIButton(frame: CGRect(x: 10, y: self.bounds.height - 50, width: 90, height: 40))
        searchWRButton.setTitle("wolfram", for: .normal)
        searchWRButton.backgroundColor = UIColor.gray
        searchWRButton.setTitleColor(UIColor.darkGray, for: .normal)
        searchWRButton.layer.cornerRadius = 7
        searchWRButton.layer.borderColor = UIColor.darkGray.cgColor
        searchWRButton.layer.borderWidth = 2
        
        

        self.addSubview(searchWRButton)
        setupConstraintsForWRQuery()
        searchWRButton.addTarget(self, action: #selector(OCRMathView.searchWRButtonTapped), for:.touchUpInside)


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
