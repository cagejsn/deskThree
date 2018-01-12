//
//  JotToMath.swift
//  deskThree
//
//  Created by Cage Johnson on 11/4/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation


class JotToMath: MAWMathView, MAWMathViewDelegate {
    
    var codeToRunUponCompletion: Action!
    
    typealias Action = ()->Void
    
    
    func mathViewDidEndRecognition(_ mathView: MAWMathView!) {
        codeToRunUponCompletion()
    }
    
    func acceptClippedStrokes(strokes: [[MAWCaptureInfo]]){
        for stroke in strokes {
            self.addStroke(stroke)
        }
        self.solve()
    }
    
    func mathViewDidBeginRecognition(_ mathView: MAWMathView!) {
        var d = 2
    }
    
    init() {
        
        super.init(frame: CGRect())
        self.delegate = self
        print(self.paddingRatio)
        // self.beautificationOption = .disabled
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCompletionBlock(codeToRun: @escaping Action){
        self.codeToRunUponCompletion = codeToRun
    }
    
    
}
