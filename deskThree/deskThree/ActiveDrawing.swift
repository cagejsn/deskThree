//
//  ActiveDrawing.swift
//  deskThree
//
//  Created by Cage Johnson on 10/30/16.
//  Copyright © 2016 desk. All rights reserved.
//


import Foundation
import MetalKit


class ActiveDrawing: MTKView  {
    
    var commandQueue: MTLCommandQueue?
    var imageTexture: MTLTexture?
    var drawStorage: StoredDrawing?
    
    var vertexData:[Float]! = nil
    
    
    
    init(frame frameRect: CGRect, device: MTLDevice?, whereToStore: StoredDrawing) {
        vertexData = [Float]()
        super.init(frame: frameRect, device: device)
        self.backgroundColor = UIColor.clear
        self.framebufferOnly = false
        drawStorage = whereToStore
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject = touches.first as UITouch!
        let touchPoint = touch.location(in: self)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject = touches.first as UITouch!
        let currentTouch = touch.location(in: self)
        let previousTouch = touch.previousLocation(in: self)
        let dx = currentTouch.x - previousTouch.x
        let dy = currentTouch.y - previousTouch.y

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUIImage(image: UIImage) {
        if let device = self.device {
            imageTexture = MTKTextureLoader(device: device).newTextureWithUIImage(image: image)
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let commandQueue = self.commandQueue, let imageTexture = self.imageTexture, let currentDrawable = self.currentDrawable {
            let commandBuffer = commandQueue.makeCommandBuffer()
            
            // Copy the image texture to the texture of the current drawable
            let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            blitEncoder.copy(from: currentDrawable.texture , sourceSlice: 0, sourceLevel: 0,
                             sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                             sourceSize: MTLSizeMake(imageTexture.width, imageTexture.height, imageTexture.depth),
                             to: (drawStorage?.storedImageTexture)!, destinationSlice: 0, destinationLevel: 0,
                             destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
            blitEncoder.endEncoding()
            
            // Present current drawable
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        }
    }
}
