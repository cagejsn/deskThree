//
//  GraphRendererHelper.m
//  deskThree
//
//  Created by Cage Johnson on 1/10/17.
//  Copyright © 2017 desk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphRendererHelper.h"

@implementation GraphRendererHelper : NSObject




-(void)setupView:(GLchar**)shaderString shader:(GLint)shader{
    glShaderSource(shader, 1, shaderString, NULL);
    glCompileShader(shader);
    return;
}

@end
