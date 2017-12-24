//
//  MathBlock.swift
//  deskThree
//
//  Created by Desk on 3/6/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation



class MathBlock: Expression{
    private var imageHolder: UIImageView?
    var mathSymbols: [Any]!
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageHolder)
        aCoder.encode(mathSymbols)
    }
    
    override func freeFromMemory(){
        super.freeFromMemory()
        
    }
    
    deinit {
        print("deinit mblock")
    }
        
    init(image: UIImage, symbols: [Any], text: String){
        
        var frame = CGRect(origin: CGPoint.zero, size: image.size)
        super.init(frame: frame)
        print(image.size)
        // Image setup
        imageHolder = UIImageView(frame: frame);
        imageHolder?.contentMode = .scaleAspectFit
        imageHolder?.image = image
        self.addSubview(imageHolder!)
        
        mathSymbols = symbols
        print(mathSymbols.count)
        expressionString = text
    }
    
    required init?(coder unarchiver: NSCoder) {
        super.init(coder: unarchiver)
        self.imageHolder = unarchiver.decodeObject() as! UIImageView!
        self.mathSymbols = unarchiver.decodeObject() as! [Any]!

    }
}
