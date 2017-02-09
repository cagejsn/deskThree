//
//  GKContext.swift
//  deskThree
//
//  Created by Cage Johnson on 1/29/17.
//  Copyright © 2017 desk. All rights reserved.
//

import Foundation

class GKContext: EAGLContext {
    
    func flush(){
        glFlush()
    }
    
}
