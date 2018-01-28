//
//  StrokeToMath.swift
//  deskThree
//
//  Created by Cage Johnson on 1/6/18.
//  Copyright © 2018 desk. All rights reserved.
//

import Foundation

class StrokeToMath: NSObject {
    
    var jotToMath: JotToMath!
    weak var page: Paper!
    weak var listener: HandledActionListener!
    
    func pushResultToPage(){
        var txt = jotToMath.resultAsText()
        if(txt == ""){ return }
        let mathimg1 = jotToMath.resultAsImage()
        if let mathimg2 = mathimg1 as? UIImage{
            let mathBlock = MathBlock(image: mathimg2, symbols: jotToMath.resultAsSymbolList(), text: jotToMath.resultAsText(), mathML: jotToMath.resultAsMathML(), data: jotToMath.serialize())
            mathBlock.center = jotToMath.center
            page.addMathBlockToPage(block: mathBlock)
            listener.actionCompleted()
        }
    }
    
    func clipperDidSelectMathWith(selection: CGPath){
        
        setupJotToMath(pathFrame: selection.boundingBox)
        var arrayOfStrokes = [JotStroke]()
        var undefStrokesOnPage = page.drawingView.state.everyVisibleStroke()
        guard let strokesOnPage = undefStrokesOnPage as? [JotStroke] else { return }
        //TODO: figure out how to not read strokes that aren't visible because of erasurement
        for s in strokesOnPage {
            if(s.strokeColor != nil){
                arrayOfStrokes.append(s)
            }
        }
        
        var output = [[MAWCaptureInfo]]()
        if let strokes = arrayOfStrokes as! [JotStroke]?{
            for strokeData in strokes {
                if let stroke = strokeData as JotStroke?{
                    var strokeForInput = [MAWCaptureInfo]()
                    if let segments = stroke.segments as! [AbstractBezierPathElement]?{
                        for segment in segments {
                            if let segment = segment as! AbstractBezierPathElement?{
                                var point = segment.startPoint
                                let drawSize = page.drawingView.pagePtSize
                                
                                point.x = point.x * (1275 / drawSize.width)
                                point.y = (point.y * -(1650 / drawSize.height)) + 1650
                                
                                if(!selection.contains(point)){
                                    continue
                                } else {
                                    point = point - jotToMath.frame.origin
                                    var captured = MAWCaptureInfo()
                                    captured.x = Float(point.x)
                                    captured.y = Float(point.y)
                                    strokeForInput.append(captured)
                                }
                            }
                        }
                        output.append(strokeForInput)
                    }
                }
            }
        }
        jotToMath.acceptClippedStrokes(strokes: output)
    }
    
    func setupJotToMath(pathFrame: CGRect){
        jotToMath = JotToMath()
        jotToMath.beautificationOption = .disabled
//        jotToMath.beautificationOption = .fontify
        jotToMath.frame = pathFrame
        // self.addSubview(jotToMath)
        jotToMath.setCompletionBlock(codeToRun: {[weak self] in return self?.pushResultToPage()})
        
        let certificate: Data = NSData(bytes: myCertificate.bytes, length: myCertificate.length) as Data
        let certificateRegistered = jotToMath.registerCertificate(certificate)
        if(certificateRegistered){
            let mainBundle = Bundle.main
            var bundlePath = mainBundle.path(forResource: "resources", ofType: "bundle") as! NSString
            bundlePath = bundlePath.appendingPathComponent("conf") as NSString
            jotToMath.addSearchDir(bundlePath as String)
            jotToMath.configure(withBundle: "math", andConfig: "standard")
        }
    }
    
    
    init(_ ownerPage: Paper) {
        self.page = ownerPage
        super.init()
    }
    
}
