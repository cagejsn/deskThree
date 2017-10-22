//
//  SelectGroupingSegmentedController.swift
//  deskThree
//
//  Created by Cage Johnson on 10/14/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

let indicatorTriangleHeight: CGFloat = 10
let indicatorTriangleHalfWidth: CGFloat = 6
let indicatorTriangeLineWidth: CGFloat = 1
let colorForIndicator: CGColor = FileExplorerColors.DarkGrey.cgColor

class SelectGroupingSegmentedControl: UISegmentedControl {
    
    typealias Action = () -> ()
    
    var segmentDidChange: Action!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.removeBorders()
        self.isMomentary = true
        self.addTarget(self, action: "handleValueChanged", for: .valueChanged)

        
      //  self.setImage(#imageLiteral(resourceName: "star-empty"), forSegmentAt: 0 )
        self.setImage(#imageLiteral(resourceName: "recycle"), forSegmentAt: 1)
        self.setImage(#imageLiteral(resourceName: "star-empty"), forSegmentAt: 2)
     //   self.setImage(#imageLiteral(resourceName: "recycle"), forSegmentAt: 3)
    }
    
    func handleValueChanged(){
        segmentDidChange()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let centerXFloat = (CGFloat(selectedSegmentIndex)+0.5) * (frame.width / CGFloat(numberOfSegments))
        let leftVertex = CGPoint( x: centerXFloat - indicatorTriangleHalfWidth, y: frame.height)
        let upperVertex = CGPoint(x: centerXFloat, y: frame.height - indicatorTriangleHeight)
        let rightVertex = CGPoint( x: centerXFloat + indicatorTriangleHalfWidth, y: frame.height)
        super.draw(rect)

        let ctx: CGContext = UIGraphicsGetCurrentContext()!;
        ctx.beginPath();
        ctx.move(to: leftVertex) //top left
        ctx.addLine(to: upperVertex) // mid right
        ctx.addLine(to: rightVertex) // bottom left
        ctx.closePath()
        ctx.setFillColor(colorForIndicator)
        ctx.fillPath()
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: .clear), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: .clear), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x:0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
