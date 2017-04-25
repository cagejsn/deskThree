//
//  UIViewExtension.swift
//  deskThree
//
//  Created by Zak Keener on 4/25/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

extension UIView {
    func round(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
