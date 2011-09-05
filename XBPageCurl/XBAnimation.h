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
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSTimeInterval duration;

+ (id)animationWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update;
- (id)initWithName:(NSString *)name duration:(NSTimeInterval)duration update:(void (^)(double t))update;
- (BOOL)step:(NSTimeInterval)dt;

@end
