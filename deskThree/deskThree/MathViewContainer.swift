//
//  MathViewContainer.swift
//  deskThree
//
//  Created by Cage Johnson on 4/25/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

let mathViewHeight: Int = 300
let mathViewWidth: Int = 600
let containerWidth: CGFloat = 600
let containerCollapsedHeight: CGFloat = 44
let containerExpandedHeight: CGFloat = 344


protocol MathViewContainerDelegate {
    func pass(_ createdMathBlock: MathBlock,for mathView: OCRMathView)
    func didRequestWRDisplay(query: String)
    func getItemForMathViewRightConstraint() -> UIView
}

class MathViewContainer: UIView, MAWMathViewDelegate, OCRMathViewDelegate {
    
    var tab: UIView!
    var mathViews: [OCRMathView]!
    private var certificateRegistered: Bool!
    var drawerPosition: DrawerPosition = .closed
    var delegate: MathViewContainerDelegate!
    
    
    var panGR: UIPanGestureRecognizer!
    var singleTapGR: UITapGestureRecognizer!
    var previousTranslation: CGFloat = 0
    
    var leftConstraint: NSLayoutConstraint!
    var bottomContraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!
    var rightConstraint: NSLayoutConstraint!


    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if(tab.frame.contains(point)){
            return true
        }
        for mathView in mathViews {
            if(mathView.frame.contains(point)){
                return true
            }
        }
        return false
    }
    
    func getViewForTopConstraint(for mathView: OCRMathView) -> UIView{
        return tab //will be expanded later
    }

    func handleSingleTap(sender: UITapGestureRecognizer){
        #if !DEBUG
            mixpanel.track(event: "Gesture: MathView: Single Touch Open/Close")
        #endif

        let location = sender.location(in: self)
        if (tab.frame.contains(location)){
            if(drawerPosition == DrawerPosition.closed){
                #if !DEBUG
                    mixpanel.track(event: "Gesture: MathView: Open")
                #endif
                
                animateToExpandedPosition()
                drawerPosition = DrawerPosition.open
                
            } else {
                #if !DEBUG
                    mixpanel.track(event: "Gesture: MathView: Close")
                #endif
                
                animateToCollapsedPosition()
                drawerPosition = DrawerPosition.closed
            }
        }
    }
    
    func handlePan(sender: UIPanGestureRecognizer){
        let currentTranslation = sender.translation(in: self).y
        var dy: CGFloat = 0
        if (sender.state == .changed){
            dy = currentTranslation - previousTranslation
            previousTranslation = currentTranslation
            if(isPanValidForMovement(dy: dy)){
                self.frame.origin.y += (dy/2)
                self.frame = self.frame.insetBy(dx: 0, dy: (dy/2))
            }
        }
        if(sender.state == .ended){
            if(self.frame.height >= (containerExpandedHeight/2)){
                animateToExpandedPosition()
                drawerPosition = DrawerPosition.open
            } else {
                animateToCollapsedPosition()
                drawerPosition = DrawerPosition.closed
            }
            previousTranslation = 0
        }
    }
    
    func isPanValidForMovement(dy: CGFloat) -> Bool{
        if (self.frame.height - dy > containerCollapsedHeight && self.frame.height - dy < containerExpandedHeight){return true}
        return false
    }
    
    
    
    func animateToCollapsedPosition(){
        self.isUserInteractionEnabled = false
        //position animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        //position animation
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        self.frame = CGRect(x: self.frame.origin.x , y:self.frame.origin.y, width: self.frame.width, height: containerCollapsedHeight)
        let originPosition: CGPoint = self.center
        let finalPosition: CGPoint = CGPoint(x: self.frame.width/2 , y: UIScreen.main.bounds.height - (containerCollapsedHeight/2))
        CATransaction.setCompletionBlock({
            self.isUserInteractionEnabled = true
        })
        positionAnimation.duration = 0.1
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.fromValue = NSValue(cgPoint: originPosition)
        positionAnimation.toValue = NSValue(cgPoint: finalPosition)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = true
        self.layer.add(positionAnimation, forKey: "positionAnimation")
        CATransaction.commit()
        self.setCollapsedHeightConstraint()
        self.center = finalPosition
        self.frame = CGRect(x:0, y: UIScreen.main.bounds.height - containerCollapsedHeight, width: self.frame.width, height: containerCollapsedHeight)
    }
    
    func animateToExpandedPosition(){
        //position animation
        self.isUserInteractionEnabled = false
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.4)
        //position animation
        let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
        self.frame = CGRect(x: self.frame.origin.x , y:self.frame.origin.y, width: self.frame.width, height: containerExpandedHeight)
        let originPosition: CGPoint = self.center
        let finalPosition: CGPoint = CGPoint(x: self.frame.width/2 , y: UIScreen.main.bounds.height - (containerExpandedHeight/2))
        CATransaction.setCompletionBlock({
            self.isUserInteractionEnabled = true
        })
        positionAnimation.duration = 0.1
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.fromValue = NSValue(cgPoint: originPosition)
        positionAnimation.toValue = NSValue(cgPoint: finalPosition)
        positionAnimation.beginTime = CACurrentMediaTime()
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = true
        self.layer.add(positionAnimation, forKey: "positionAnimation")
        CATransaction.commit()
        self.setExpandedHeightConstraint()
        self.center = finalPosition
        self.frame = CGRect(x:0, y: UIScreen.main.bounds.height - containerExpandedHeight, width: self.frame.width, height: containerExpandedHeight)
    }
    
    func setCollapsedHeightConstraint(){
        superview?.removeConstraint(heightContraint)
        heightContraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: containerCollapsedHeight)
        superview!.addConstraint(heightContraint)
    }
    
    func setExpandedHeightConstraint(){
        superview?.removeConstraint(heightContraint)
        heightContraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: containerExpandedHeight)
        superview!.addConstraint(heightContraint)
    }
    
    func setupConstraints(){
        self.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: 0)
        bottomContraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1.0, constant: 0)
        heightContraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: containerCollapsedHeight)
        rightConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: delegate.getItemForMathViewRightConstraint(), attribute: .leading, multiplier: 1.0, constant: 40)
        superview!.addConstraints([leftConstraint,bottomContraint,heightContraint,rightConstraint])
    }

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
    
    func setupTabConstraints(){
        tab.translatesAutoresizingMaskIntoConstraints = false
        let margins = self.layoutMarginsGuide
       // tab.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
       // tab.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        tab.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        tab.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        tab.heightAnchor.constraint(equalToConstant: 44).isActive = true
        tab.widthAnchor.constraint(equalToConstant: 100).isActive = true
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
//            mathView.round(corners: [.topLeft, .topRight], radius: 5.0)
        }
    }
    
    func stylize( mathView: OCRMathView){
        mathView.setupMathViewConstraints()
      //  mathView.layer.borderColor = Constants.DesignColors.deskBlue.cgColor
       // mathView.layer.borderWidth = 5

        mathView.stylize()
        
        
        
        
        //mathView.addTopBorder(color: Constants.DesignColors.deskBlue, width: 5)
    }
    
    
    
    func setup(mathView: OCRMathView){
        mathView.delegate = self
        mathView.beautificationOption = MAWBeautifyOption.fontify
        mathView.delegate2 = self
    }
    
    func receiveElement(_ element: MathBlock){
    }
    
    func addMathViewToStack(){
        var mathView = OCRMathView(frame: CGRect(x: 0, y: (mathViews.count * mathViewHeight) + 44, width: mathViewWidth, height: mathViewHeight))
        setupMyscriptCertificate(for: mathView)
        setup(mathView: mathView)
        self.addSubview(mathView)
        stylize(mathView: mathView)
        mathViews.append(mathView)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tab = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        tab.backgroundColor = UIColor.init(red: 41.0/255.0, green: 183.0/255.0, blue: 235.0/255.0, alpha: 0.75)
        tab.center.x = self.center.x
        tab.round(corners: [.topLeft, .topRight], radius: 5.0)
        self.addSubview(tab)
        setupTabConstraints()
        
        
        
        mathViews = [OCRMathView]()
        addMathViewToStack()
        
        // Add the swipe gesture for sliding out
        panGR = UIPanGestureRecognizer(target: self, action: #selector(ToolDrawer.handlePan))
        tab.addGestureRecognizer(panGR)
        
        // Add the tap gesture for sliding out
        singleTapGR = UITapGestureRecognizer(target: self, action: #selector(ToolDrawer.handleSingleTap))
        self.addGestureRecognizer(singleTapGR)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
