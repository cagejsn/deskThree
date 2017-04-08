//
//  UImage+ImageOrientationFix.swift
//  deskThree
//
//  Created by Cage Johnson on 11/30/16.
//  Copyright © 2016 desk. All rights reserved.
//
/*
import Foundation
extension UIImage {
    
    func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        var radians: CGFloat = CGFloat(GLKMathDegreesToRadians(Float(degrees)))
        
        var rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        var t: CGAffineTransform = CGAffineTransform(rotationAngle: radians)
        var rotatedSize: CGSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, UIScreen.main.scale)
        var bitmap: CGContext = UIGraphicsGetCurrentContext()!
        
        CGContext
        
    }
    
    
}
 
 */

/*
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {
    CGFloat radians = DegreesToRadians(degrees);
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radians);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    CGContextRotateCTM(bitmap, radians);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2 , self.size.width, self.size.height), self.CGImage );
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
 */
