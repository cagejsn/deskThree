//
//  graphContext.swift
//  deskThree
//
//  Created by Cage Johnson on 1/10/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class GraphContext: EAGLContext {
    
    
    func flush(){
        glFlush()
    }
}
