//
//  XBAnimation.m
//  XBPageCurl
//
//  Created by xiss burg on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBAnimation.h"


@interface XBAnimation ()

@property (nonatomic, copy) void (^update)(double t);

@end


@implementation XBAnimation

@synthesize name=_name, duration=_duration, update=_update, interpolator=_interpolator;

+ (id)animationWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double))update
{
    return [self animationWithName:name duration:duration update:update interpolator:XBAnimationInterpolatorEaseInOut];
}

+ (id)animationWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update interpolator:(double (^)(double))interpolator
{
    return [[[self alloc] initWithName:name duration:duration update:update interpolator:interpolator] autorelease];
}

- (id)initWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double))update
{
    return [self initWithName:name duration:duration update:update interpolator:XBAnimationInterpolatorEaseInOut];
}

- (id)initWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update interpolator:(double (^)(double))interpolator
{
    self = [super init];
    if (self) {
        self.name = name;
        _duration = duration;
        _update = [update copy];
        _interpolator = [interpolator copy];
        _elapsedTime = 0;
    }
    return self;
}

- (void)dealloc
{
    self.name = nil;
    self.update = nil;
    self.interpolator = nil;
    [super dealloc];
}

- (BOOL)step:(NSTimeInterval)dt
{
    _elapsedTime += dt;
    
    if (_elapsedTime > _duration) {
        _update(1.0);
        return NO;
    }
    
    double t = self.interpolator(_elapsedTime/_duration);
    self.update(t);
    
    return YES;
}

@end


/*
 * Default interpolators implementation.
 */

double (^XBAnimationInterpolatorLinear)(double t) = ^(double t)
{
    return t;
};

double (^XBAnimationInterpolatorEaseInOut)(double t) = ^(double t)
{    
    return 0.5 * (1 - cos(t*M_PI));
};

double (^XBAnimationInterpolatorEaseIn)(double t) = ^(double t)
{    
    return t*t;
};

double (^XBAnimationInterpolatorEaseOut)(double t) = ^(double t)
{    
    double t1 = t - 1;
    return 1 - t1*t1;
};

