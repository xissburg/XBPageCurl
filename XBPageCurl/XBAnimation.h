//
//  XBAnimation.h
//  XBPageCurl
//
//  Created by xiss burg on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Simple class for animations.
 */
@interface XBAnimation : NSObject {
@private
    NSTimeInterval _duration;
    NSTimeInterval _elapsedTime;
    void (^_update)(double t);
    double (^_interpolator)(double t);
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, copy) double (^interpolator)(double t);

+ (id)animationWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update;
+ (id)animationWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update interpolator:(double (^)(double t))interpolator;
- (id)initWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update;
- (id)initWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update interpolator:(double (^)(double t))interpolator;
- (BOOL)step:(NSTimeInterval)dt;

@end


/*
 * Default interpolators.
 */
double (^XBAnimationInterpolatorLinear)(double t);
double (^XBAnimationInterpolatorEaseInOut)(double t);
double (^XBAnimationInterpolatorEaseIn)(double t);
double (^XBAnimationInterpolatorEaseOut)(double t);