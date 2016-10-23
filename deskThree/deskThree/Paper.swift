//
//  Paper.swift
//  deskThree
//
//  Created by Cage Johnson on 10/23/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import UIKit

class Paper: UIImageView, ImageBlockDelegate {
    
    //MARK: Initializers
    init() {
        super.init(frame: CGRect(x: 10, y: 10, width: 400, height: 400))
        self.image = UIImage(named: "engineeringPaper")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //ImageBlock Delegate Functions
    func fixImageToWorkArea(image: ImageBlock){
        
    }
    
    func freeImageForMovement(image: ImageBlock){
        
    }
}
