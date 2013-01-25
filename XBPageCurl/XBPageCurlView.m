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
@property (nonatomic, readwrite) CGFloat cylinderAngle;
@end

@implementation XBPageCurlView

@synthesize delegate, snappingPoints, snappingEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.snappingPoints = [NSMutableArray array];
        self.snappingEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    self.snappingPoints = nil;
}

#pragma mark - Methods

- (XBSnappingPoint *)snappingPointNearestToPoint:(CGPoint)v {
    XBSnappingPoint *closestSnappingPoint;
    
    CGFloat d = FLT_MAX;
    //Find the snapping point closest to the cylinder axis
    for (XBSnappingPoint *snappingPoint in self.snappingPoints) {
        //Compute the distance between the snappingPoint.position and the cylinder axis
        CGFloat dSq = CGPointToLineDistance(snappingPoint.position, self.cylinderPosition, v);
        if (dSq < d) {
            closestSnappingPoint = snappingPoint;
            d = dSq;
        }
    }
    return closestSnappingPoint;
}

- (void)snapToPoint:(XBSnappingPoint *)snappingPoint {
    if ([self.delegate respondsToSelector:@selector(pageCurlView:willSnapToPoint:)]) {
        [self.delegate pageCurlView:self willSnapToPoint:snappingPoint];
    }
    
    // @todo shouldn't these animate too?
    [self setCylinderPosition:snappingPoint.position animatedWithDuration:kDuration];
    [self setCylinderAngle:snappingPoint.angle animatedWithDuration:kDuration];
    
    XBPageCurlView __weak *_self = self;
    [self setCylinderRadius:snappingPoint.radius animatedWithDuration:kDuration completion:^{
        XBPageCurlView *blockSelf = _self;
        if ([blockSelf.delegate respondsToSelector:@selector(pageCurlView:didSnapToPoint:)]) {
            [blockSelf.delegate pageCurlView:blockSelf didSnapToPoint:snappingPoint];
        }
    }];
}

- (void)updateCylinderStateWithPoint:(CGPoint)p animated:(BOOL)animated
{
    CGPoint v = CGPointSub(p, startPickingPosition);
    CGFloat l = CGPointLength(v);
    
    if (fabs(l) < FLT_EPSILON) {
        return;
    }
    
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
    
    NSTimeInterval duration = animated? kDuration: 0;
    [self setCylinderPosition:c animatedWithDuration:duration];
    
    // @todo Add option to set angle based on vector heading from start of drag
    // so the curls up from wherever you starterd
    //[self setCylinderAngle:angle animatedWithDuration:duration];
    
    [self setCylinderRadius:r animatedWithDuration:duration];
}

- (void)beginCurlingAtPoint:(CGPoint)p
{
    p.y = self.bounds.size.height - p.y;
    
    CGPoint v = CGPointMake(cosf(self.cylinderAngle), sinf(self.cylinderAngle));
    CGPoint vp = CGPointRotateCW(v);
    CGPoint p0 = p;
    CGPoint p1 = CGPointAdd(p0, CGPointMul(vp, 12345.6));
    CGPoint q0 = CGPointMake(self.bounds.size.width, 0);
    CGPoint q1 = CGPointMake(self.bounds.size.width, self.bounds.size.height);
    CGPoint x = CGPointZero;
    
    if (CGPointIntersectSegments(p0, p1, q0, q1, &x)) {
        startPickingPosition = x;
    }
    else {
        startPickingPosition.x = self.bounds.size.width;
        startPickingPosition.y = p.y;
    }
    
    [self updateCylinderStateWithPoint:p animated:YES];
}

- (void)moveCurlToPoint:(CGPoint)p
{
    p.y = self.bounds.size.height - p.y;
    [self updateCylinderStateWithPoint:p animated:NO];
}

- (void)endCurlingAtPoint:(CGPoint)p
{
    if (self.snappingEnabled && self.snappingPoints.count > 0) {
        XBSnappingPoint *closestSnappingPoint = nil;
        CGPoint v = CGPointMake(cosf(self.cylinderAngle), sinf(self.cylinderAngle));
        
        closestSnappingPoint = [self snappingPointNearestToPoint:v];

        NSAssert(closestSnappingPoint != nil, @"There is always a closest point in a non-empty set of points hence closestSnappingPoint should not be nil.");
        
        [self snapToPoint:closestSnappingPoint];
    }
}


@end