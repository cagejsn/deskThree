//
//  GraphingBlock.swift
//  deskThree
//
//  Created by Cage Johnson on 1/12/17.
//  Copyright © 2017 desk. All rights reserved.
//

/*
extension CALayer {
    
    
    func bringSublayerToFront(layer:CALayer){
        layer.removeFromSuperlayer()
        self.insertSublayer(layer, at: UInt32((self.sublayers?.count)!))
    
    }
    
    func sendSublayerToBack(layer:CALayer){
        layer.removeFromSuperlayer()
        self.insertSublayer(layer, at: 0)
    }
    
}
 */

let borderWidth:CGFloat = 7

import Foundation
import QuartzCore

class GraphingBlock: UIView {
    
    var graphToManage: GraphView!
    var borderLayer: CALayer!
    var zoomGestureRecognizer: UIPinchGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var translationOfPan: CGPoint!
    var startingGraphScale: CGFloat = 1
    var graphScale: CGFloat = 1
    var deltaScale: CGFloat = 0
    var touched: Bool = false
    
    
    @IBOutlet var xMinLabel: UILabel!
    @IBOutlet var xMaxLabel: UILabel!
    @IBOutlet var yMinLabel: UILabel!
    @IBOutlet var yMaxLabel: UILabel!
    
    
    //properties about graphToManage
    var xMin: GLfloat = -1
    var xMax: GLfloat = 1
    var yMin: GLfloat = -1
    var yMax: GLfloat = 1
    
    
    func updateGraphLabels(){
        xMinLabel.text = String(format: "%.2f", xMin)
        xMaxLabel.text = String(format: "%.2f", xMax)
        yMinLabel.text = String(format: "%.2f", yMin)
        yMaxLabel.text = String(format: "%.2f", yMax)
    }
    
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = true
        setNeedsDisplay()
        updateGraphLabels()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first?.location(in: self)
        let prevTouchLocation = touches.first?.previousLocation(in: self)
        let dX =  touchLocation!.x - prevTouchLocation!.x
        let dY =  touchLocation!.y - prevTouchLocation!.y
        self.frame.origin.x += dX
        self.frame.origin.y += dY
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched = false
        setNeedsDisplay()
    }
    
    
    func coordsOfGraphCenter() -> CGPoint {
        return CGPoint(x: CGFloat(((xMax - xMin) / 2) + xMin) , y: CGFloat(((yMax - yMin) / 2) + yMin))
    }
    
    
    
    //finally figured it out!
    // you need to find the center, then calculate the amount that xMin and xMax (and Y) are away from that center
    // then you mulitply by the percent change in the scale and adjust the numbers accordingly.
    
    
    
    func handlePinch(sender: UIPinchGestureRecognizer){
        
        
    
        if (sender.state == .began){
           // deltaScale = sender.scale
        
            
        }
        
        if (sender.state == .changed){
            deltaScale = ((sender.scale * startingGraphScale) - graphScale) / graphScale
            graphScale = sender.scale * startingGraphScale
            
            
            xMax = GLfloat(CGFloat(1 - graphToManage.glYAxisLocation) / graphScale)
            xMin = GLfloat(CGFloat(-1 - graphToManage.glYAxisLocation) / graphScale)
            yMax = GLfloat(CGFloat(1 - graphToManage.glXAxisLocation) / graphScale)
            yMin = GLfloat(CGFloat(-1 - graphToManage.glXAxisLocation) / graphScale)
            updateGraphLabels()
            
            graphToManage.glYAxisLocation += CFloat(deltaScale ) * graphToManage.glYAxisLocation
            graphToManage.glXAxisLocation += CFloat(deltaScale ) * graphToManage.glXAxisLocation
            graphToManage.setupAxesVertices()
            graphToManage.render()
            
            print(graphScale)
        }
        
        if (sender.state == .ended){
            startingGraphScale = graphScale
            deltaScale = 0
        }
        
      
    }
    
    func handlePan(sender: UIPanGestureRecognizer){
        if (sender.state == .began){
            translationOfPan = sender.translation(in: self)
        }
        
        if (sender.state == .changed){
            let dX = Float(sender.translation(in: self).x - translationOfPan.x) / Float(self.frame.width / 2)
            let dY = Float(sender.translation(in: self).y - translationOfPan.y) / Float(self.frame.height / 2)
            translationOfPan = sender.translation(in: self)
            xMin -= (dX / Float(graphScale))
            xMax -= (dX / Float(graphScale))
            yMin += (dY / Float(graphScale))
            yMax += (dY / Float(graphScale))
            updateGraphLabels()
            graphToManage.glYAxisLocation += dX
            graphToManage.glXAxisLocation -= dY
            graphToManage.setupAxesVertices()
            graphToManage.render()
        }
        
        if (sender.state == .ended){
            translationOfPan = nil
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        graphToManage = GraphView(frame: CGRect(x:borderWidth,y:borderWidth,width: self.frame.width - (2 * borderWidth), height: self.frame.height - (2 * borderWidth)), context: EAGLContext(api: .openGLES2 ))
        self.addSubview(graphToManage)
        
        borderLayer = CALayer()
        borderLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.layer.insertSublayer(borderLayer, above: graphToManage.layer)
        
        borderLayer.cornerRadius = 10
        borderLayer.borderWidth = borderWidth
        borderLayer.borderColor = UIColor.gray.cgColor
        
        zoomGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.addGestureRecognizer(zoomGestureRecognizer)
        zoomGestureRecognizer.isEnabled = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GraphingBlock.handlePan(sender:)))
       // panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        self.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.minimumNumberOfTouches = 2
        panGestureRecognizer.maximumNumberOfTouches = 2
        panGestureRecognizer.isEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        
        graphToManage = GraphView(frame: CGRect(x:borderWidth,y:borderWidth,width: self.frame.width - (2 * borderWidth), height: self.frame.height - (2 * borderWidth)), context: EAGLContext(api: .openGLES2 ))
       self.addSubview(graphToManage)
        
        borderLayer = CALayer()
        borderLayer.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.layer.insertSublayer(borderLayer, above: graphToManage.layer)
        
        self.sendSubview(toBack: graphToManage)
        
        borderLayer.cornerRadius = 10
        borderLayer.borderWidth = borderWidth
        borderLayer.borderColor = UIColor.gray.cgColor
        
        zoomGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(GraphingBlock.handlePinch(sender:)))
        self.addGestureRecognizer(zoomGestureRecognizer)
        zoomGestureRecognizer.isEnabled = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GraphingBlock.handlePan(sender:)))
        self.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 2
        panGestureRecognizer.isEnabled = true

        }
    
    
    
}
