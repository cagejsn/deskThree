//
//  MathBlock.swift
//  deskThree
//
//  Created by Desk on 3/6/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

protocol MathBlockDelegate {
    func didHoldBlock(sender: MathBlock)
}

class MathBlock: Expression{
    var delegate2: MathBlockDelegate!
    private var imageHolder: UIImageView!
    var mathSymbols: [Any]!
    private var longPressGR: UILongPressGestureRecognizer!
    
    override func encode(with aCoder: NSCoder) {

        aCoder.encode(imageHolder)
        aCoder.encode(mathSymbols)
        aCoder.encode(longPressGR)
        super.encode(with: aCoder)
    }
    
    // Make DVC a delegate for longpress to work when mathView is not a subview
    func handleLongPress(){
        delegate2.didHoldBlock(sender:self)
    }
    
        
    init(image: UIImage, symbols: [Any], text: String){
        let frame = image.size
        super.init(frame: CGRect(x:0, y: 0, width: frame.width/3, height: frame.height/3))
        print(image.size)
        // Image setup
        imageHolder = UIImageView(frame: CGRect(x:0, y:0, width: frame.width/2.5, height: frame.height/2.5));
        imageHolder.contentMode = .scaleAspectFit
        imageHolder.image = image
        self.addSubview(imageHolder)
        
        mathSymbols = symbols
        print(mathSymbols.count)
        expressionString = text
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(MathBlock.handleLongPress))
        longPressGR.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGR)
    }
    
    required init?(coder unarchiver: NSCoder) {
        self.imageHolder = unarchiver.decodeObject() as! UIImageView!
        self.mathSymbols = unarchiver.decodeObject() as! [Any]!
        self.longPressGR = unarchiver.decodeObject() as! UILongPressGestureRecognizer!
        super.init(coder: unarchiver)
        
    }
}
