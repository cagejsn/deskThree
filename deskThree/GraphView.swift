//
//  graphBlock.swift
//  deskThree
//
//  Created by Cage Johnson on 1/10/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import OpenGLES
import GLKit

struct Vertex {
    var Position: (CFloat, CFloat, CFloat)
    var Color: (CFloat, CFloat, CFloat, CFloat)
}

//helper extensions to pass arguments to GL land
extension Array {
    func size () -> Int {
        return self.count * MemoryLayout.size(ofValue: self[0])
    }
}

extension Int32 {
    func __conversion() -> GLenum {
        return GLuint(self)
    }
    
    func __conversion() -> GLboolean {
        return GLboolean(UInt8(self))
    }
}

extension Int {
    func __conversion() -> Int32 {
        return Int32(self)
    }
    
    func __conversion() -> GLubyte {
        return GLubyte(self)
    }
}


struct Mark {
    var glXPosition: CFloat
    var glYPosition: CFloat
    var halfHeight: CFloat
    var halfWidth: CFloat
}

let axesHalfWidth: CFloat = 0.002
let arrowLength: CFloat = 0.04
let arrowHalfWidth: CFloat = 0.02
let bigMarkerHalfHeight: CFloat = 0.015
let bigMarkerHalfWidth: CFloat = 0.008

class GraphView: GLKView {
    
    var colorRenderBuffer: GLuint = GLuint()
    var positionSlot: GLuint = GLuint()
    var colorSlot: GLuint = GLuint()
    var indexBuffer: GLuint = GLuint()
    var vertexBuffer: GLuint = GLuint()
    var VAO:GLuint = GLuint()
    var eaglLayer: CAEAGLLayer!
    
    var glYAxisLocation: CFloat = 0
    var glXAxisLocation: CFloat = 0
    
    var bigMarkerSpacing: CFloat = 0.2
    
    var lastSwitch: CFloat = 1


    var Vertices: [Vertex]!    
    var Indices: [GLuint]!
    
    var bigMarkers: [Mark]!
    var littleMarkers: [Mark]!
    
    
    
    
    
    
  
    func addAxesToBuffer(){
        Vertices = [
            /* x axis */
            Vertex(Position: (-1 + arrowLength, -axesHalfWidth + glXAxisLocation, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (-1 + arrowLength, axesHalfWidth + glXAxisLocation, 0)  , Color: (0, 1, 0, 1)),
            Vertex(Position: (1-arrowLength, axesHalfWidth + glXAxisLocation, 0) , Color: (0, 0, 1, 1)),
            Vertex(Position: (1-arrowLength, -axesHalfWidth + glXAxisLocation, 0)  , Color: (0, 1, 0, 1)),
            
            /* y axis */
            Vertex(Position: (-axesHalfWidth + glYAxisLocation, -1+arrowLength, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (axesHalfWidth + glYAxisLocation, -1+arrowLength, 0)  , Color: (0, 1, 0, 1)),
            Vertex(Position: (-axesHalfWidth + glYAxisLocation, 1-arrowLength, 0) , Color: (0, 0, 1, 1)),
            Vertex(Position: (axesHalfWidth + glYAxisLocation, 1-arrowLength, 0)  , Color: (0, 1, 0, 1)),
            
            /* + x axis arrows  indices 8, 9, 10*/
            Vertex(Position: (1, glXAxisLocation, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (1-arrowLength, arrowHalfWidth + glXAxisLocation, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (1-arrowLength, -arrowHalfWidth + glXAxisLocation, 0) , Color: (1, 0, 0, 1)),
            
            /* - x axis arrows  indices 11, 12, 13*/
            Vertex(Position: (-1, glXAxisLocation, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (-1+arrowLength, arrowHalfWidth + glXAxisLocation, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (-1+arrowLength, -arrowHalfWidth + glXAxisLocation, 0) , Color: (1, 0, 0, 1)),
            
            /* + y axis arrows  indices 14, 15, 16*/
            Vertex(Position: (glYAxisLocation, 1, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (-arrowHalfWidth + glYAxisLocation, 1-arrowLength, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (arrowHalfWidth + glYAxisLocation, 1-arrowLength, 0) , Color: (1, 0, 0, 1)),
            
            /* - y axis arrows  indices 17, 18, 19*/
            Vertex(Position: (glYAxisLocation, -1, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (-arrowHalfWidth + glYAxisLocation, -1+arrowLength, 0) , Color: (1, 0, 0, 1)),
            Vertex(Position: (arrowHalfWidth + glYAxisLocation, -1+arrowLength, 0) , Color: (1, 0, 0, 1)),
        ]
        
       Indices = [
        0, 1, 2,
        2, 3, 0,
        4, 5, 6,
        5, 6, 7,
        8, 9, 10,
        11,12,13,
        14,15,16,
        17,18,19,
        ]
    }
    
    
    func addMarkersToBuffer(){
      
        addMarkersToBuffer(for: littleMarkers)
        addMarkersToBuffer(for: bigMarkers)
    }
    
    
   
    private func addMarkersToBuffer(for markers: [Mark]){
      
        for mark in markers {
            Vertices.append(Vertex(Position: (mark.glXPosition - mark.halfWidth, -mark.halfHeight + mark.glYPosition, 0) , Color: (1, 0, 0, 1)))
            Vertices.append(Vertex(Position: (mark.glXPosition - mark.halfWidth, mark.halfHeight + mark.glYPosition, 0) , Color: (1, 0, 0, 1)))
            Vertices.append(Vertex(Position: (mark.glXPosition + mark.halfWidth, mark.halfHeight + mark.glYPosition, 0) , Color: (1, 0, 0, 1)))
            Vertices.append(Vertex(Position: (mark.glXPosition + mark.halfWidth, -mark.halfHeight + mark.glYPosition, 0) , Color: (1, 0, 0, 1)))
        }
        
        var cd: Int = 0
        if (Indices[Indices.count - 1] != 19){
        cd = Int(Indices[Indices.count - 1]) + 4 // this pattern will only hold for markers
        } else { cd = 20 }
      
        for i in stride(from: Int(cd) , through: Int(cd) + ((markers.count - 1) * 4), by: 4) {
        Indices.append(GLuint(i))
        Indices.append(GLuint(i+1))
        Indices.append(GLuint(i+2))
            
        Indices.append(GLuint(i+2))
        Indices.append(GLuint(i+3))
        Indices.append(GLuint(i))
        }
    }
    
    
    
    
    
    func createBigMarks(){
        bigMarkers = [Mark]()
        
        var place = glYAxisLocation
        while (place < -1){
            place = place + 2
        }
        
        while (place > 1){
            place = place - 2
        }
        
        for i in -25 ... 25 {
            bigMarkers.append(Mark(glXPosition: place + (bigMarkerSpacing * Float(i)), glYPosition: glXAxisLocation, halfHeight: 0.01, halfWidth: 0.01))
        }
    }
    
    func createlittleMarks(){
        littleMarkers = [Mark]()
        
        var place = glYAxisLocation
        while (place < -1){
            place = place + 2
        }
        
        while (place > 1){
            place = place - 2
        }
        
        for i in -40 ... 40{
        littleMarkers.append(Mark(glXPosition: place + ((bigMarkerSpacing/5) * Float(i)), glYPosition: glXAxisLocation, halfHeight: 0.006, halfWidth: 0.006))
        }
    }
    
    
    func updateMarkerFeatures(graphScale: CGFloat){
        
        if (Float(graphScale) < (lastSwitch / 5)){
            lastSwitch = CFloat(graphScale)
        }
        
        
        if (Float(graphScale) > (lastSwitch * 5)) {
            lastSwitch = CFloat(graphScale)
        }
        
        bigMarkerSpacing = Float(graphScale / 5) / lastSwitch
        
        
        print(Float(graphScale)/Float(lastSwitch))
        
        
        
        
        
        if ( Float(graphScale)/Float(lastSwitch) <= 1 ){
            bigMarkerSpacing *= 5
            createlittleMarks()
            createBigMarks()
        }
        
        
        
        if ( Float(graphScale)/Float(lastSwitch) > 1 ){
            createlittleMarks()
            createBigMarks()
        }
        
    }
    
    
    override init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame, context: context)
        createlittleMarks()
        createBigMarks()
        addAxesToBuffer()
        self.eaglLayer = self.layer as! CAEAGLLayer
        self.layer.isOpaque = false
        EAGLContext.setCurrent(self.context)
        contentScaleFactor = 1.0
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.compileShaders()
       // self.setupVBOs()
        self.render()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    //OpenGLCodes
    
    func setupRenderBuffer() {
        glGenRenderbuffers(1, &self.colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from:self.eaglLayer)
    }
    
    func setupFrameBuffer() {
        var frameBuffer: GLuint = GLuint()
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
    }
    
    func compileShader(shaderName: String, shaderType: GLenum) -> GLuint {
        
        // Get NSString with contents of our shader file.
        let shaderPath: String! = Bundle.main.path(forResource: shaderName, ofType: "glsl")
        var error: NSError? = nil
        var shaderString: NSString
        do { shaderString = try NSString(contentsOfFile:shaderPath, encoding: String.Encoding.utf8.rawValue)} catch {print("Failed to set contents shader of shader file!"); shaderString = ""
        }
        
        
        // Tell OpenGL to create an OpenGL object to represent the shader, indicating if it's a vertex or a fragment shader.
        var shaderHandle: GLuint = glCreateShader(shaderType)
        
        if shaderHandle == 0 {
            NSLog("Couldn't create shader")
        }
        // Conver shader string to CString and call glShaderSource to give OpenGL the source for the shader.
        var shaderStringUTF8 = shaderString.utf8String
        var shaderStringLength: GLint = GLint(Int32(shaderString.length))
        glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength)
        
        // Tell OpenGL to compile the shader.
        glCompileShader(shaderHandle)
        
        // But compiling can fail! If we have errors in our GLSL code, we can here and output any errors.
        var compileSuccess: GLint = GLint()
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if (compileSuccess == GL_FALSE) {
            print("Failed to compile shader!")
            // TODO: Actually output the error that we can get from the glGetShaderInfoLog function.
            exit(1);
        }
        
        return shaderHandle
    }
    
    func compileShaders() {
        
        // Compile our vertex and fragment shaders.
        var vertexShader: GLuint = self.compileShader(shaderName: "vertexShader", shaderType: GLenum(GL_VERTEX_SHADER))
        var fragmentShader: GLuint = self.compileShader(shaderName: "fragmentShader", shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        // Call glCreateProgram, glAttachShader, and glLinkProgram to link the vertex and fragment shaders into a complete program.
        var programHandle: GLuint = glCreateProgram()
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        glLinkProgram(programHandle)
        
        // Check for any errors.
        var linkSuccess: GLint = GLint()
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        if (linkSuccess == GL_FALSE) {
            print("Failed to create shader program!")
            // TODO: Actually output the error that we can get from the glGetProgramInfoLog function.
            exit(1);
        }
        
        // Call glUseProgram to tell OpenGL to actually use this program when given vertex info.
        glUseProgram(programHandle)
        
        // Finally, call glGetAttribLocation to get a pointer to the input values for the vertex shader, so we
        //  can set them in code. Also call glEnableVertexAttribArray to enable use of these arrays (they are disabled by default).
        self.positionSlot = GLuint(glGetAttribLocation(programHandle, "Position"))
        self.colorSlot = GLuint(glGetAttribLocation(programHandle, "SourceColor"))
        glEnableVertexAttribArray(self.positionSlot)
        glEnableVertexAttribArray(self.colorSlot)
    }
    
    // Setup Vertex Buffer Objects
    func setupVBOs() {
        
        glGenVertexArraysOES(1, &VAO);
        glBindVertexArrayOES(VAO);
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
        
        //        let positionSlotFirstComponent : UnsafePointer<Int>(&0)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(MemoryLayout<Vertex>.size), nil)
        
        glEnableVertexAttribArray(colorSlot)
        //        let colorSlotFirstComponent = UnsafePointer<Int>(sizeof(Float) * 3)
        glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(MemoryLayout<Vertex>.size), nil)
        
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), Indices.size(), Indices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
    }
    
    func clear(){
        glColor4f(0.0, 0.0, 0.0, 0.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

    }
    
    func render() {
        
        
        glGenVertexArraysOES(1, &VAO);
        glBindVertexArrayOES(VAO);
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
        
        //        let positionSlotFirstComponent : UnsafePointer<Int>(&0)
        glEnableVertexAttribArray(positionSlot)
        glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(MemoryLayout<Vertex>.size), nil)
        
        glEnableVertexAttribArray(colorSlot)
        //        let colorSlotFirstComponent = UnsafePointer<Int>(sizeof(Float) * 3)
        glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(MemoryLayout<Vertex>.size), nil)
        
        glGenBuffers(1, &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), Indices.size(), Indices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
        
        
        
        
        glBindVertexArrayOES(VAO);
        glViewport(0, 0, GLint(self.frame.size.width), GLint(self.frame.size.height));
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_INT), nil)
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        glBindVertexArrayOES(0)

    }
    
    
    override func draw(_ rect: CGRect) {
      
       
    }
    
    
}













