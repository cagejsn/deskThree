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
    var mathML: String!
    var data: Data!
    
    
    func updateContents(_ newText: String,_ newImage: UIImage ,_ newMathSymbols: [Any],_ newMathML: String, _ newData: Data){
        var sizeDifference: CGSize = CGSize(width:self.frame.size.width - newImage.size.width, height: self.frame.size.height - newImage.size.height)
        
        self.frame = self.frame.insetBy(dx: sizeDifference.width / 2, dy: sizeDifference.height / 2)
//        var keepTheSameCenter = self.center
        
        let newFrame = CGRect(origin: CGPoint.zero, size: newImage.size)
        
        //get rid of old image
        imageHolder?.removeFromSuperview()
        
        // newImage setup
        imageHolder = UIImageView(frame: newFrame);
        imageHolder?.contentMode = .scaleAspectFit
        imageHolder?.image = newImage
        self.addSubview(imageHolder!)
        
        mathSymbols = newMathSymbols
        expressionString = newText
        mathML = newMathML
        data = newData
        
        AnalyticsManager.track(.EditLinkedBlock)
    }
    
    func getMathML() -> String {
        return mathML
    }
    
    func getData() -> Data {
        return data
    }

    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageHolder)
        aCoder.encode(mathSymbols)
        aCoder.encode(mathML)
        aCoder.encode(data)
    }
    
    override func freeFromMemory(){
        super.freeFromMemory()
        
    }
    
    deinit {
        print("deinit mblock")
    }
        
    init(image: UIImage, symbols: [Any], text: String, mathML: String, data: Data){
        
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
        self.mathML = mathML
        self.data = data
    }
    
    required init?(coder unarchiver: NSCoder) {
        super.init(coder: unarchiver)
        self.imageHolder = unarchiver.decodeObject() as! UIImageView!
        self.mathSymbols = unarchiver.decodeObject() as! [Any]!
        self.mathML = unarchiver.decodeObject() as! String!
        self.data = unarchiver.decodeData()
    }
}
