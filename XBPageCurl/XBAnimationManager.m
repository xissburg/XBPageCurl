//
//  XBAnimationManager.m
//  XBPageCurl
//
//  Created by xiss burg on 9/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBAnimationManager.h"
#import "XBAnimation.h"


@interface XBAnimationManager ()

@property (nonatomic, retain) NSMutableDictionary *animations;
@property (nonatomic, retain) NSMutableArray *animationsToRemove;
@property (nonatomic, assign) BOOL updateLock;

@end


@implementation XBAnimationManager

@synthesize animations=_animations, animationsToRemove=_animationsToRemove;

- (id)init
{
    self = [super init];
    if (self) {
        _animations = [[NSMutableDictionary alloc] init];
        _animationsToRemove = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    self.animations = nil;
    self.animationsToRemove = nil;
    [super dealloc];
}


#pragma mark - Methods

+ (id)animationManager
{
    return [[[self alloc] init] autorelease];
}

- (void)runAnimation:(XBAnimation *)animation
{
    [self.animations setObject:animation forKey:animation.name];
}

- (void)stopAnimation:(XBAnimation *)animation
{
    [self stopAnimationNamed:animation.name];
}

- (void)stopAnimationNamed:(NSString *)name
{
    if (self.updateLock) {
        [self.animationsToRemove addObject:name];
    }
    else {
        [self.animations removeObjectForKey:name];
    }
}

- (void)stopAllAnimations
{
    if (self.updateLock) {
        [self.animationsToRemove addObjectsFromArray:[self.animations allKeys]];
    }
    else {
        [self.animations removeAllObjects];
    }
}

- (void)update:(double)dt
{
    //Step all animations
    NSMutableArray *finishedAnimationKeys = [NSMutableArray array];//animations to be removed
    
    self.updateLock = YES;
    [self.animations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        XBAnimation *animation = (XBAnimation *)obj;
        if ([animation step:dt] == NO) {
            [finishedAnimationKeys addObject:key];
        }
    }];
    self.updateLock = NO;
    
    [self.animations removeObjectsForKeys:finishedAnimationKeys];
    [self.animations removeObjectsForKeys:self.animationsToRemove];
    [self.animationsToRemove removeAllObjects];
}

@end
