//
//  JotStroke.m
//  JotTouchExample
//
//  Created by Adam Wulf on 1/9/13.
//  Copyright (c) 2013 Milestone Made. All rights reserved.
//

#import "JotStroke.h"
#import "SegmentSmoother.h"
#import "AbstractBezierPathElement.h"
#import "AbstractBezierPathElement-Protected.h"
#import "JotDefaultBrushTexture.h"
#import "JotGLColorlessPointProgram.h"
#import "UIColor+JotHelper.h"

#import "NSArray+JotMapReduce.h"
#import "JotBufferVBO.h"
#import "JotBufferManager.h"
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import "JotUI.h"


@implementation JotStroke {
    // this will interpolate between points into curved segments
    SegmentSmoother* segmentSmoother;
    // this is the texture to use when drawing the stroke
    JotBrushTexture* texture;
    //color of the stroke
    UIColor* strokeColor;
    __weak NSObject<JotStrokeDelegate>* delegate;
    // total Byte size
    NSInteger totalNumberOfBytes;
    // buffer manager to use for this stroke
    JotBufferManager* bufferManager;
    // lock
    NSRecursiveLock* lock;
}

@synthesize segments;
@synthesize segmentSmoother;
@synthesize texture;
@synthesize strokeColor;
@synthesize delegate;
@synthesize totalNumberOfBytes;
@synthesize bufferManager;


- (id)initWithTexture:(JotBrushTexture*)_texture andBufferManager:(JotBufferManager*)_bufferManager {
    if (self = [self init]) {
        if (!_texture) {
            @throw [NSException exceptionWithName:@"TextureException" reason:@"Texture for stroke is nil" userInfo:nil];
        }
        segmentSmoother = [[SegmentSmoother alloc] init];
        texture = _texture;
//        strokeColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        bufferManager = _bufferManager;
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        segments = [NSMutableArray array];
        hashCache = 1;
        lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (int)fullByteSize {
    int totalBytes = 0;
    @synchronized(segments) {
        if (segments && [segments count]) {
            for (AbstractBezierPathElement* ele in segments) {
                totalBytes += ele.fullByteSize;
            }
        }
    }
    return totalBytes;
}


- (void)addElement:(AbstractBezierPathElement*)element {
    [self lock];
    element.bufferManager = self.bufferManager;
    NSInteger numOfElementBytes = [element numberOfBytesGivenPreviousElement:[segments lastObject]];
    int numOfCacheBytes = [JotBufferVBO cacheNumberForBytes:numOfElementBytes] * kJotBufferBucketSize;
    totalNumberOfBytes += numOfElementBytes + numOfCacheBytes;

    if ([segments count]) {
        if ((element.color && ![(AbstractBezierPathElement*)[segments lastObject] color]) ||
            (!element.color && [(AbstractBezierPathElement*)[segments lastObject] color])) {
            NSAssert((element.color && [(AbstractBezierPathElement*)[segments lastObject] color]) ||
                         (!element.color && ![(AbstractBezierPathElement*)[segments lastObject] color]),
                     @"color (or lack thereof) must match previous segment");
        }
    }
    @synchronized(segments) {
        [segments addObject:element];
    }
    [self updateHashWithObject:element];
    [self unlock];
}

/**
 * removes an element from this stroke,
 * but does not update the hash. this should
 * only be used to manage memory for a slow
 * dealloc situation
 */
- (void)removeElementAtIndex:(NSInteger)index {
    [self lock];
    @synchronized(segments) {
        [segments removeObjectAtIndex:index];
    }
    [self unlock];
}

- (void)cancel {
    [self.delegate strokeWasCancelled:self];
}

- (void)empty {
    @synchronized(segments) {
        [segments removeAllObjects];
    }
}

- (CGRect)bounds {
    if ([self.segments count]) {
        CGRect bounds = [[self.segments objectAtIndex:0] bounds];
        @synchronized(segments) {
            for (AbstractBezierPathElement* ele in self.segments) {
                bounds = CGRectUnion(bounds, ele.bounds);
            }
        }
        return bounds;
    }
    return CGRectZero;
}


#pragma mark - Encoding & Decoding


- (void)encodeWithCoder:(NSCoder *)aCoder {
   // [aCoder encodeObject:NSStringFromClass([self class]) forKey:@"class"];
    [aCoder encodeObject:segments forKey:@"segments"];
    [aCoder encodeObject:segmentSmoother forKey:@"segmentSmoother"];
    [aCoder encodeObject:texture forKey:@"texture"];
    [aCoder encodeObject:strokeColor forKey:@"strokeColor"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        segments = [aDecoder decodeObjectForKey:@"segments"];
        segmentSmoother = [aDecoder decodeObjectForKey:@"segmentSmoother"];
        texture = [aDecoder decodeObjectForKey:@"texture"];
        strokeColor = [aDecoder decodeObjectForKey:@"strokeColor"];
    }
    return self;
}

#pragma mark - PlistSaving

- (NSDictionary*)asDictionary {
    @synchronized(segments) {
        NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"JotStroke", @"class",
                                   [self.segments jotMapWithSelector:@selector(asDictionary)], @"segments",
                                   [self.segmentSmoother asDictionary], @"segmentSmoother",
                                   [self.texture asDictionary], @"texture",
                                   [self.strokeColor asDictionary], @"strokeColor",
                                   nil];
        return dictionary;
    }
}

- (id)initLightFromDict:(NSDictionary*)dictionary {
    if (self = [super init]) {
        // hashCache = 1;
        // segmentSmoother = [[SegmentSmoother alloc] initFromDictionary:[dictionary objectForKey:@"segmentSmoother"]];
        // bufferManager = [dictionary objectForKey:@"bufferManager"];
        __block AbstractBezierPathElement* previousElement = nil;
        segments = [NSMutableArray arrayWithArray:[[dictionary objectForKey:@"segments"] jotMap:^id(id obj, NSUInteger index) {
            NSString* className = [obj objectForKey:@"class"];
            Class class = NSClassFromString(className);
            AbstractBezierPathElement* segment = [[class alloc] initFromDictionary:obj];
            // [segment setBufferManager:bufferManager];
            //   [self updateHashWithObject:segment];
            //  totalNumberOfBytes += [segment numberOfBytesGivenPreviousElement:previousElement];
            [segment validateDataGivenPreviousElement:previousElement]; // nil out our dictionary loaded data if it's the wrong size
            //  [segment loadDataIntoVBOIfNeeded]; // generate if if needed
            previousElement = segment;
            return segment;
        }]];
        // texture = [[JotBrushTexture alloc] initFromDictionary:[dictionary objectForKey:@"texture"]];
    }
    return self;
}

- (id)initFromDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        hashCache = 1;
        strokeColor = [UIColor colorWithDictionary:[dictionary objectForKey:@"strokeColor"]];
        segmentSmoother = [[SegmentSmoother alloc] initFromDictionary:[dictionary objectForKey:@"segmentSmoother"]];
        bufferManager = [dictionary objectForKey:@"bufferManager"];
        __block AbstractBezierPathElement* previousElement = nil;
        segments = [NSMutableArray arrayWithArray:[[dictionary objectForKey:@"segments"] jotMap:^id(id obj, NSUInteger index) {
            NSString* className = [obj objectForKey:@"class"];
            Class class = NSClassFromString(className);
            AbstractBezierPathElement* segment = [[class alloc] initFromDictionary:obj];
            [segment setBufferManager:bufferManager];
            [segment setColor: self.strokeColor];
            
            [self updateHashWithObject:segment];
            totalNumberOfBytes += [segment numberOfBytesGivenPreviousElement:previousElement];
            [segment validateDataGivenPreviousElement:previousElement]; // nil out our dictionary loaded data if it's the wrong size
            [segment loadDataIntoVBOIfNeeded]; // generate if if needed
            previousElement = segment;
            return segment;
        }]];
        texture = [[JotBrushTexture alloc] initFromDictionary:[dictionary objectForKey:@"texture"]];
    }
    return self;
}


#pragma mark - hashing and equality

- (void)updateHashWithObject:(NSObject*)obj {
    NSUInteger prime = 31;
    hashCache = prime * hashCache + [obj hash];
}

- (NSUInteger)hash {
    return hashCache;
}

- (NSString*)uuid {
    return [NSString stringWithFormat:@"%lu", (unsigned long)[self hash]];
}

- (BOOL)isEqual:(id)object {
    return self == object || [self hash] == [object hash];
}

- (void)lock {
    [lock lock];
}

- (void)unlock {
    [lock unlock];
}

#pragma mark - Scaling

- (void)scaleSegmentsForWidth:(CGFloat)widthRatio andHeight:(CGFloat)heightRatio {
    [segmentSmoother scaleForWidth:widthRatio andHeight:heightRatio];

    [segments enumerateObjectsUsingBlock:^(AbstractBezierPathElement* ele, NSUInteger idx, BOOL* _Nonnull stop) {
        [ele scaleForWidth:widthRatio andHeight:heightRatio];
    }];
}

@end
