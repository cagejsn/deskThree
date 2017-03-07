//
//  MathBlock.swift
//  deskThree
//
//  Created by Desk on 3/6/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class MathBlock: Expression{
    var imageHolder: UIImageView!
    var mathSymbols: [MAWSymbol] = []
    
    init(image: UIImage, symbols: NSArray, text: String){
        super.init(frame: CGRect(x:0, y:0, width: 200, height: 100))
        // Image setup
        imageHolder = UIImageView(frame: CGRect(x:0, y:0, width: 200, height: 40));
        imageHolder.contentMode = .scaleAspectFit
        imageHolder.image = image;
        self.addSubview(imageHolder)
        
        mathSymbols = symbols as! [MAWSymbol]
        expressionString = text
    }
    
    required init?(coder unarchiver: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
