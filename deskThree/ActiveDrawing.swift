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
    
    var vertexData:[Float]! = nil
    var vertexBuffer: MTLBuffer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var timer: CADisplayLink! = nil
    var renderable: Bool = false
    
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        
        super.init(frame: frameRect, device: device)
        
        vertexData = [Float]()

        
        self.backgroundColor = UIColor.clear
        self.framebufferOnly = false
        
        // 1
        let defaultLibrary = device?.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex")
        
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        // 3
        var pipelineError : MTLNewRenderPipelineStateCompletionHandler
        
        do {
            pipelineState = try device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
        } catch {
            print("wft")
        }
        
        if pipelineState == nil {
            // print("Failed to create pipeline state, error \(pipelineError)")
        }
        
        
        timer = CADisplayLink(target: self, selector: Selector("gameloop"))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
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
        
        /*
        if ( abs(dx + dy) < 1){
            return
        }
*/
        
        var touch1X = ((currentTouch.x / self.frame.maxX) * 2) - 1
        var touch1Y = (-(currentTouch.y / self.frame.maxY) * 2) + 1
        
        var touch2X = ((previousTouch.x / self.frame.maxX) * 2) - 1
        var touch2Y = (-(previousTouch.y / self.frame.maxY) * 2) + 1
        
        var i = Float(touch1X)
        var j = Float(touch1Y)
        var k:Float = 0
        
        vertexData.removeAll()

        while k < 6.28 {
            vertexData.append(Float((sin(k)/8) + i))
            vertexData.append(Float((cos(k)/14) + j))
            vertexData.append(Float(0))
            
            k += 1
            
            vertexData.append(Float((sin(k)/8) + i))
            vertexData.append(Float((cos(k)/14) + j))
            vertexData.append(Float(0))
            
            vertexData.append(Float(i))
            vertexData.append(Float(j))
            vertexData.append(Float(0))
        }
        renderable = true

        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
        vertexBuffer = device?.makeBuffer(bytes: vertexData, length: dataSize, options: .optionCPUCacheModeWriteCombined)
    
        
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUIImage(image: UIImage) {
        if let device = self.device {
            imageTexture = MTKTextureLoader(device: device).newTextureWithUIImage(image: image)
        }
    }
    
    func render() {
        var drawable = self.currentDrawable
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable!.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let renderEncoderOpt = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        if let renderEncoder = renderEncoderOpt as MTLRenderCommandEncoder! {
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
            renderEncoder.endEncoding()
        }
        commandBuffer?.present(drawable!)
        commandBuffer?.commit()
    }
    
    func gameloop() {
        autoreleasepool {
            if(renderable){
            self.render()
                renderable = false
            }
        }
    }
}
