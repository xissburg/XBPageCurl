//
//  XBAnimation.m
//  XBPageCurl
//
//  Created by xiss burg on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBAnimation.h"

@implementation XBAnimation

@synthesize name=_name, duration=_duration;

+ (id)animationWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update
{
    return [[[self alloc] initWithName:name duration:duration update:update] autorelease];
}

- (id)initWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update
{
    self = [super init];
    if (self) {
        self.name = name;
        _duration = duration;
        _update = [update copy];
        _elapsedTime = 0;
    }
    return self;
}

- (void)dealloc
{
    [_update release];
    [_name release];
    [super dealloc];
}

- (BOOL)step:(NSTimeInterval)dt
{
    _elapsedTime += dt;
    
    if (_elapsedTime > _duration) {
        _update(1.0);
        return NO;
    }
    
    _update(_elapsedTime/_duration);
    
    return YES;
}

@end

