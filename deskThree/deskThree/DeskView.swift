//
//  DeskView.swift
//  deskThree
//
//  Created by Cage Johnson on 2/11/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class DeskView: UIView {
    
    var workArea: WorkArea!
    var jotView: JotView!
        
    func setup(){

    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
            return nil
        }
        var  time = CACurrentMediaTime()
        for view in workArea.currentPage.subviews {
            
        }
        time -= CACurrentMediaTime()
        print("lag from iterating = " + String(time))
        
        if(self.point(inside: point, with: event)){
            for subView: UIView in self.subviews {
                var convertedPoint = self.convert(point, to: subView)
                var hitTestView = subView.hitTest(convertedPoint, with: event)
                if((hitTestView) != nil){
                    return hitTestView
                }
            }
            return self
        }
        return nil
    }
    
}
