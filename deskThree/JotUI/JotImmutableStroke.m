//
//  JotImmutableStroke.m
//  JotUI
//
//  Created by Adam Wulf on 6/22/13.
//  Copyright (c) 2013 Milestone Made. All rights reserved.
//

#import "JotImmutableStroke.h"
#import "UIColor+JotHelper.h"


@implementation JotImmutableStroke {
    SegmentSmoother* segmentSmoother;
    // this will store all the segments in drawn order
    NSArray* segments;
    // this is the texture to use when drawing the stroke
    JotBrushTexture* texture;
    UIColor* strokeColor;
    NSString* uuid;
    //
    NSString* strokeClassName;
}

- (id)initWithJotStroke:(JotStroke*)stroke {
    if (self = [super init]) {
        segmentSmoother = stroke.segmentSmoother;
        segments = [NSArray arrayWithArray:stroke.segments];
        texture = stroke.texture;
        strokeColor = stroke.strokeColor;
        uuid = [stroke uuid];
        strokeClassName = NSStringFromClass([stroke class]);
    }
    return self;
}

- (NSMutableArray*)segments {
    return [NSMutableArray arrayWithArray:segments];
}

- (SegmentSmoother*)segmentSmoother {
    return segmentSmoother;
}

- (JotBrushTexture*)texture {
    return texture;
}

- (UIColor*)strokeColor {
    return strokeColor;
}

- (NSString*)uuid {
    return uuid;
}




- (NSDictionary*)asDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[super asDictionary]];
    [dict setObject:strokeClassName forKey:@"class"];
    return dict;
}


@end
