//
//  MathBlock.swift
//  deskThree
//
//  Created by Desk on 3/6/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class MathBlock: Expression{
    private var imageHolder: UIImageView!
    private var mathSymbols: [MAWSymbol] = []
    private var longPressGR: UILongPressGestureRecognizer!
    
    func handleLongPress(){
        
    }
    
    init(image: UIImage, symbols: NSArray, text: String){
        var frame = image.size
        super.init(frame: CGRect(frame))
        print(image.size)
        // Image setup
        imageHolder = UIImageView(frame: CGRect(x:0, y:0, width: 70, height: 40));
        imageHolder.contentMode = .scaleAspectFit
        imageHolder.image = image
        self.addSubview(imageHolder)
        
        mathSymbols = symbols as! [MAWSymbol]
        expressionString = text
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(MathBlock.handleLongPress))
        longPressGR.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGR)
    }
    
    required init?(coder unarchiver: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
