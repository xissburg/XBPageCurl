//
//  XBAnimationTest.m
//  XBPageCurl
//
//  Created by xiss burg on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "XBAnimation.h"
#import "XBAnimationManager.h"


@interface XBAnimationTest : GHTestCase
@end


@implementation XBAnimationTest


- (void)testAnimationStepping
{
    double duration = 3;
    __block double et = 0;
    XBAnimation *animation = [XBAnimation animationWithName:@"animation" duration:duration update:^(double t) {
        et = t;
    }];
    
    [animation step:0];
    GHAssertEqualsWithAccuracy(et, 0.0, DBL_EPSILON, @"Value should still be zero");
    
    [animation step:duration/2];
    GHAssertEqualsWithAccuracy(et, 0.5, DBL_EPSILON, @"Value should be 1.0/2");
    
    [animation step:duration/2];
    GHAssertEqualsWithAccuracy(et, 1.0, DBL_EPSILON, @"Value should be 1.0, final");
}

- (void)testAnimationInterpolator
{
    
}

@end
