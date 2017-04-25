//
//  CALayerExtension.swift
//  deskThree
//
//  Created by Zak Keener on 4/25/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

extension CALayer {
//    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
//        let maskPath = UIBezierPath(roundedRect: bounds,
//                                    byRoundingCorners: corners,
//                                    cornerRadii: CGSize(width: radius, height: radius))
//        
//        let shape = CAShapeLayer()
//        shape.path = maskPath.cgPath
//        mask = shape
//    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat, viewBounds: CGRect) {
        
        let maskPath = UIBezierPath(roundedRect: viewBounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        mask = shape
    }

}
