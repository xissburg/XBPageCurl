//
//  XBPageCurlView.m
//  XBPageCurl
//
//  Created by xiss burg on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBPageCurlView.h"
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

- (void)updateCylinderStateWithPoint:(CGPoint)p animatedWithDuration:(NSTimeInterval)duration
{
    CGPoint v = CGPointSub(p, startPickingPosition);
    CGFloat l = CGPointLength(v);
    CGFloat r = 16 + l/8;
    CGFloat d = 0; // Displacement of the cylinder position along the segment with direction v starting at startPickingPosition
    CGFloat quarterDistance = (M_PI_2 - 1)*r; // Distance ran by the finger to make the cylinder perform a quarter turn
    
    if (l < quarterDistance) {
        d = (l/quarterDistance)*(M_PI_2*r);
    }
    else if (l < M_PI*r) {
        d = (((l - quarterDistance)/(M_PI*r - quarterDistance)) + 1)*(M_PI_2*r);
    }
    else {
        d = M_PI*r + (l - M_PI*r)/2;
    }
    
    CGPoint vn = CGPointMul(v, 1.f/l); //Normalized
    CGPoint c = CGPointAdd(startPickingPosition, CGPointMul(vn, d));
    CGFloat angle = atan2f(-vn.x, vn.y);
    
    if (duration > 0) {
        [self setCylinderPosition:c animatedWithDuration:duration];
        [self setCylinderAngle:angle animatedWithDuration:duration];
        [self setCylinderRadius:r animatedWithDuration:duration];
    }
    else {
        self.cylinderPosition = c;
        self.cylinderAngle = angle;
        self.cylinderRadius = r;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    p.y = self.bounds.size.height - p.y;
    
    CGPoint v = CGPointMake(cosf(_cylinderAngle), sinf(_cylinderAngle));
    CGPoint vp = CGPointRotateCW(v);
    CGPoint p0 = p;
    CGPoint p1 = CGPointAdd(p0, CGPointMul(vp, 12345.6));
    CGPoint q0 = CGPointMake(self.bounds.size.width, 0);
    CGPoint q1 = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    CGPoint x = CGPointZero;
    
    if (CGPointIntersectSegments(p0, p1, q0, q1, &x))
    {
        startPickingPosition = x;
    }
    else {
        startPickingPosition.x = self.bounds.size.width;
        startPickingPosition.y = p.y;
    }
    
    [self updateCylinderStateWithPoint:p animatedWithDuration:kDuration];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    p.y = self.bounds.size.height - p.y;
    [self updateCylinderStateWithPoint:p animatedWithDuration:0];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.snappingEnabled && self.snappingPoints.count > 0) {
        XBSnappingPoint *closestSnappingPoint = nil;
        CGFloat d = 123456789.f;
        CGPoint v = CGPointMake(cosf(_cylinderAngle), sinf(_cylinderAngle));
        //Find the snapping point closest to the cylinder axis
        for (XBSnappingPoint *snappingPoint in self.snappingPoints) {
            //Compute the distance between the snappingPoint.position and the cylinder axis
            CGFloat dSq = CGPointToLineDistance(snappingPoint.position, _cylinderPosition, v);
            if (dSq < d) {
                closestSnappingPoint = snappingPoint;
                d = dSq;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(pageCurlView:willSnapToPoint:)]) {
            [self.delegate performSelector:@selector(pageCurlView:willSnapToPoint:) withObject:closestSnappingPoint];
        }
        
        [self setCylinderPosition:closestSnappingPoint.position animatedWithDuration:kDuration];
        [self setCylinderAngle:closestSnappingPoint.angle animatedWithDuration:kDuration];
        [self setCylinderRadius:closestSnappingPoint.radius animatedWithDuration:kDuration completion:^{
            if ([self.delegate respondsToSelector:@selector(pageCurlView:didSnapToPoint:)]) {
                [self.delegate performSelector:@selector(pageCurlView:didSnapToPoint:) withObject:closestSnappingPoint];
            }
        }];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

@end