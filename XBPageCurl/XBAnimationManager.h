//
//  XBAnimationManager.h
//  XBPageCurl
//
//  Created by xiss burg on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class XBAnimation;


@interface XBAnimationManager : NSObject {
    NSMutableDictionary *_animations;
}

+ (id)animationManager;

- (void)runAnimation:(XBAnimation *)animation;
- (void)stopAnimation:(XBAnimation *)animation;
- (void)stopAnimationNamed:(NSString *)name;

- (void)update:(NSTimeInterval)dt;

@end
