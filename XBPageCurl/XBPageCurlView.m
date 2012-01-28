//
//  XBPageCurlView.m
//  XBPageCurl
//
//  Created by xiss burg on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBPageCurlView.h"
#import "XBSnappingPoint.h"
#import "CGPointAdditions.h"

#define kDuration 0.3


@interface XBPageCurlView ()



@end


@implementation XBPageCurlView

@synthesize delegate, snappingPoints, snappingEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.snappingPoints = [NSMutableArray array];
        self.snappingEnabled = NO;
    }
    return self;
}

- (void)dealloc
{
    self.snappingPoints = nil;
    [super dealloc];
}


#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint p = [[touches anyObject] locationInView:self];
    p.y = self.bounds.size.height - p.y;
    startPickingPosition.x = self.bounds.size.width;
    startPickingPosition.y = p.y;
    
    [self setCylinderPosition:p animatedWithDuration:kDuration];
    
    CGPoint dir = CGPointMake(startPickingPosition.x-p.x, startPickingPosition.y-p.y);
    dir = CGPointMake(-dir.y, dir.x);
    CGFloat length = sqrtf(dir.x*dir.x + dir.y*dir.y);
    dir.x /= length, dir.y /= length;
    CGFloat angle = atan2f(dir.y, dir.x);
    
    [self setCylinderAngle:angle animatedWithDuration:kDuration];
    [self setCylinderRadius:16+length/4 animatedWithDuration:kDuration];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    CGPoint p = [[touches anyObject] locationInView:self];
    p.y = self.bounds.size.height - p.y;
    self.cylinderPosition = p;
    CGPoint dir = CGPointMake(startPickingPosition.x-self.cylinderPosition.x, startPickingPosition.y-self.cylinderPosition.y);
    dir = CGPointMake(-dir.y, dir.x);
    CGFloat length = sqrtf(dir.x*dir.x + dir.y*dir.y);
    dir.x /= length, dir.y /= length;
    CGFloat angle = atan2f(dir.y, dir.x);
    
    self.cylinderAngle = angle;
    self.cylinderRadius = 16 + length/4;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.snappingEnabled && self.snappingPoints.count > 0) {
        XBSnappingPoint *closestSnappingPoint = nil;
        CGFloat d = 123456789.f;
        CGPoint v = CGPointMake(cosf(_cylinderAngle), sinf(_cylinderAngle));
        //Find the snapping point closest to the cylinder axis
        for (XBSnappingPoint *snappingPoint in self.snappingPoints) {
            //Compute the distance between the snappingPoint.position and the cylinder axis
            CGPoint p = snappingPoint.position;
            CGPoint w = CGPointSub(p, _cylinderPosition);
            CGFloat s = CGPointDot(w, v)/CGPointDot(v, v);
            CGPoint q = CGPointAdd(_cylinderPosition, CGPointMul(v, s));
            CGFloat dSq = CGPointLengthSq(CGPointSub(q, p));
            
            if (dSq < d) {
                closestSnappingPoint = snappingPoint;
                d = dSq;
            }
        }
        
        [self setCylinderPosition:closestSnappingPoint.position animatedWithDuration:kDuration];
        [self setCylinderAngle:closestSnappingPoint.angle animatedWithDuration:kDuration];
        [self setCylinderRadius:closestSnappingPoint.radius animatedWithDuration:kDuration];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

@end