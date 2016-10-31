//
//  DrawingLayer.swift
//  deskThree
//
//  Created by Cage Johnson on 10/30/16.
//  Copyright © 2016 desk. All rights reserved.
//

import Foundation
import MetalKit

extension MTKTextureLoader {
    
    func newTextureWithUIImage(image: UIImage) -> MTLTexture? {
        if let cgImage = image.cgImage {
            do {
                return try newTexture(with: cgImage, options: nil)
            } catch let error as NSError {
                print("[ERROR] - Failed to create a new MTLTexture from the CGImage. \(error)")
            }
        } else {
            print("[ERROR] - Failed to get a CGImage from the UIImage.")
        }
        return nil
    }
}


class StoredDrawing: MTKView  {
    
    var commandQueue: MTLCommandQueue?
    var storedImageTexture: MTLTexture?
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        self.backgroundColor = UIColor.clear
        self.framebufferOnly = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUIImage(image: UIImage) {
        if let device = self.device {
            storedImageTexture = MTKTextureLoader(device: device).newTextureWithUIImage(image: image)
        }
    }
    
   override func draw(_ rect: CGRect) {
        if let commandQueue = self.commandQueue, let storedImageTexture = self.storedImageTexture, let currentDrawable = self.currentDrawable {
            let commandBuffer = commandQueue.makeCommandBuffer()
            
            // Copy the image texture to the texture of the current drawable
            let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            blitEncoder.copy(from: storedImageTexture, sourceSlice: 0, sourceLevel: 0,
                             sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                             sourceSize: MTLSizeMake(storedImageTexture.width, storedImageTexture.height, storedImageTexture.depth),
                             to: currentDrawable.texture, destinationSlice: 0, destinationLevel: 0,
                                        destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
            blitEncoder.endEncoding()
            
            // Present current drawable
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        }
    }
}
