//
//  MathViewContainer.swift
//  deskThree
//
//  Created by Cage Johnson on 4/25/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

let MathViewHeight: Int = 300
let MathViewWidth: Int = 600

protocol MathViewContainerDelegate {
    func pass(_ createdMathBlock: MathBlock,for mathView: OCRMathView)
    func didRequestWRDisplay(query: String)
}

class MathViewContainer: UIView, MAWMathViewDelegate, OCRMathViewDelegate {
    
    var mathViews: [OCRMathView]!
    private var certificateRegistered: Bool!
    var drawerPosition: DrawerPosition!
    var delegate: MathViewContainerDelegate!
    
    //MARK: OCRMathViewDelegate Functions
    func createMathBlock(for mathView: OCRMathView){
        
        if let image1 =  mathView.resultAsImage(){
            let mathBlock = MathBlock(image: image1, symbols: mathView.resultAsSymbolList(), text: mathView.resultAsText())
            delegate.pass(mathBlock,for:mathView)
        }
        
        
    }
    
    func didRequestWRDisplay(query: String){
        delegate.didRequestWRDisplay(query: query)
    }
    
    
    //MARK: MAWMathViewDelegate Functions
    
    func mathViewDidBeginConfiguration(_ mathView: MAWMathView!) {
        
    }
    
    func mathView(_ mathView: MAWMathView!, didFailConfigurationWithError error: Error!) {
        NSLog("unable to config", error.localizedDescription)
        print(error.localizedDescription)
    }
    
    func mathViewDidBeginRecognition(_ mathView: MAWMathView!) {
        
    }
    
    func mathViewDidEndRecognition(_ mathView: MAWMathView!) {
        
    }
    
    
    
    
    
    
    
    func setupMyscriptCertificate(for mathView: MAWMathView){
        let certificate: Data = NSData(bytes: myCertificate.bytes, length: myCertificate.length) as Data
        certificateRegistered = mathView.registerCertificate(certificate)
        if(certificateRegistered!){
            let mainBundle = Bundle.main
            var bundlePath = mainBundle.path(forResource: "resources", ofType: "bundle") as! NSString
            bundlePath = bundlePath.appendingPathComponent("conf") as NSString
            mathView.addSearchDir(bundlePath as String)
            mathView.configure(withBundle: "math", andConfig: "standard")
            mathView.paddingRatio = UIEdgeInsetsMake(7, 7, 7, 7)
        }
    }
    
    func stylize( mathView: OCRMathView){
        
    }
    
    func setup(mathView: OCRMathView){
        mathView.delegate = self
        mathView.beautificationOption = MAWBeautifyOption.fontify
        mathView.delegate2 = self

    }
    
    func receiveElement(_ element: MathBlock){
        
    }
    
    func addMathViewToStack(){
        var mathView = OCRMathView(frame: CGRect(x: 0, y: mathViews.count * MathViewHeight, width: MathViewWidth, height: MathViewHeight))
        setupMyscriptCertificate(for: mathView)
        setup(mathView: mathView)
        stylize(mathView: mathView)
        mathViews.append(mathView)
        self.addSubview(mathView)
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mathViews = [OCRMathView]()
        addMathViewToStack()
        
        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}
