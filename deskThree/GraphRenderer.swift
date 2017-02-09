//
//  GraphRenderer.swift
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

var Vertices = [
    Vertex(Position: (1, -1, 0) , Color: (1, 0, 0, 1)),
    Vertex(Position: (1, 1, 0)  , Color: (0, 1, 0, 1)),
    Vertex(Position: (-1, 1, 0) , Color: (0, 0, 1, 1)),
    Vertex(Position: (-1, -1, 0), Color: (0, 0, 0, 1))
]

var Indices: [GLubyte] = [
    0, 1, 2,
    2, 3, 0
]



class GraphRenderer: NSObject, GLKViewDelegate {
    
    var owner: GraphBlock
    
    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    var colorRenderBuffer: GLuint = GLuint()
    var positionSlot: GLuint = GLuint()
    var colorSlot: GLuint = GLuint()
    var indexBuffer: GLuint = GLuint()
    var vertexBuffer: GLuint = GLuint()
    var VAO:GLuint = GLuint()
    
    /* Delegate Methods
    ------------------------------------------*/
    
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        /*
        if owner.touched {
            glClearColor(0.3, 0.1, 0.9, 1.0)
        } else {
            glClearColor(0.1, 0.3, 0.9, 1.0)
        }
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        */
        glBindVertexArrayOES(VAO);
        glViewport(0, 0, GLint(owner.frame.size.width), GLint(owner.frame.size.height));
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
        glBindVertexArrayOES(0)

    }
    
    
    /* Class Methods
     ------------------------------------------*/
    
    /*
    
    override class var layerClass: AnyClass {
        // In order for our view to display OpenGL content, we need to set it's
        //   default layer to be a CAEAGLayer
        return CAEAGLLayer.self
    }
    */
    
    /* Lifecycle
     ------------------------------------------*/
    
    init(forGraphBlock: GraphBlock) {
        owner = forGraphBlock

        super.init()
        self.setupLayer()
        self.setupContext()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.compileShaders()
        self.setupVBOs()
        self.render()
    }
    /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.setupLayer()
        self.setupContext()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.compileShaders()
        self.setupVBOs()
        self.render()
    }
    */
    
    
    /* Instance Methods
     ------------------------------------------*/
    
    func setupLayer() {
        // CALayer's are, by default, non-opaque, which is 'bad for performance with OpenGL',
        //   so let's set our CAEAGLLayer layer to be opaque.
        self.eaglLayer = owner.layer as! CAEAGLLayer
       // self.eaglLayer = CAEAGLLayer()
        self.eaglLayer.isOpaque = true
    }
 
    
    func setupContext() {
        // Just like with CoreGraphics, in order to do much with OpenGL, we need a context.
        //   Here we create a new context with the version of the rendering API we want and
        //   tells OpenGL that when we draw, we want to do so within this context.
        let api: EAGLRenderingAPI = EAGLRenderingAPI.openGLES2
        self.context = EAGLContext(api: api)
        
        if (self.context == nil) {
            print("Failed to initialize OpenGLES 2.0 context!")
            exit(1)
        }
        
        if (!EAGLContext.setCurrent(self.context)) {
            print("Failed to set current OpenGL context!")
            exit(1)
        }
    }
    
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
        var vertexShader: GLuint = self.compileShader(shaderName: "shader", shaderType: GLenum(GL_VERTEX_SHADER))
        var fragmentShader: GLuint = self.compileShader(shaderName: "fragShader", shaderType: GLenum(GL_FRAGMENT_SHADER))
        
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
    
    func render() {
       
        }
}


/*
class GraphRenderer: NSObject, GLKViewDelegate {
    
    let graphBlock: GraphBlock!
    var myHelper: GraphRendererHelper!
    
   // let vertexShaderSource = "#version 330 core\n layout (location = 0) in vec3 position;\n void main()\n {\n gl_Position = vec4(position.x, position.y,position.z, 1.0);\n }\n"
    
   // let vertexShaderSource = "void main() { gl_Position = vec4(position.x, position.y,position.z, 1.0);}"
    
  //  let vertexShaderSource = "void main() { gl_Position = ftransform();}"
    
   // let vertexShaderSource = "void main(void) /n { vec4 a = gl_Vertex; a.x = a.x * 0.5; a.y = a.y * 0.5; gl_Position = gl_ModelViewProjectionMatrix * a; }"
    
    let fragmentShaderSource = "#version 330 core\n" +
        "out vec4 color;\n" +
        "void main()\n" +
        "{\n" +
        "color = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n" +
    "}\n"
    
    
    
    
    
    
    let vertices:[GLfloat] = [
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        0.0,  0.5, 0.0
    ]
    
    let indices:[GLint] = [1]
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        if graphBlock.touched {
            glClearColor(0.3, 0.1, 0.9, 1.0)
        } else {
            glClearColor(0.1, 0.3, 0.9, 1.0)
        }
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glDrawElements(GLenum(GL_TRIANGLES), 1, GLenum(GL_FLOAT), indices)
        
    }
    
    
    init(forGraphBlock: GraphBlock){
        graphBlock = forGraphBlock
        myHelper = GraphRendererHelper()
        
        let shaderProgram:GLuint = glCreateProgram()
        let vertexShader:GLuint = glCreateShader(GLenum(GL_VERTEX_SHADER))
        
        var vShaderFile = Bundle.main.path(forResource: "shader", ofType: "glsl")
        var vShaderSource: String
        
        do {
            vShaderSource = try NSString(contentsOfFile: vShaderFile!, encoding: String.Encoding.utf8.rawValue ) as String
        } catch { print("oh no"); vShaderSource = "fuck"    }
        
        var d = UnsafePointer.init(vShaderSource.cString(using: String.Encoding.utf8))
       
   //     print(d!.pointee)
    //    var a: GLint = GLint(vertexShaderSource.lengthOfBytes(using: .utf8))
        var cStringOfShaderSource = vShaderSource.cString(using: .utf8)
     //   var d = UnsafeMutablePointer(mutating: cStringOfShaderSource)
       // myHelper.setupView(&d)
     //   myHelper.setupView(&d, shader: GLint(vertexShader))
        
        glShaderSource(vertexShader, 1, &d, nil)
        
        
        glCompileShader(vertexShader)
        
        var success:GLint = 0
        glGetShaderiv(vertexShader, GLenum(GL_SHADER_SOURCE_LENGTH), &success)
        
        var infoLog = [GLchar](repeating: 0, count: 512)
        
        guard success == GL_TRUE else
        {
            glGetShaderInfoLog(vertexShader, 512, nil, &infoLog)
            
            fatalError(String.init(validatingUTF8:infoLog)!)
            
        }
        
        
        //step 1
        var VBO:GLuint = 0
        glGenBuffers(1, &VBO)
        defer { glDeleteBuffers(1, &VBO) }
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
        
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     MemoryLayout<GLfloat>.stride * vertices.count,
                     vertices, GLenum(GL_STATIC_DRAW))
        
        
        
        
        var VAO:GLuint = 0
        glGenVertexArrays(1, &VAO)
        defer { glDeleteVertexArrays(1, &VAO) }
        
        // ..:: Initialization code (done once (unless your object frequently changes)) :: ..
        // 1. Bind Vertex Array Object
        glBindVertexArray(VAO)
        // 2. Copy our vertices array in a buffer for OpenGL to use
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     MemoryLayout<GLfloat>.stride * vertices.count,
                     vertices, GLenum(GL_STATIC_DRAW))
        // 3. Then set our vertex attributes pointers
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT),
                              UInt8(false), GLsizei(MemoryLayout<GLfloat>.stride * 3), nil)
        glEnableVertexAttribArray(0)
        //4. Unbind the VAO
        glBindVertexArray(0)
        
        
        
    }
    
}

*/
