//
//  CGPointAdditions.c
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "CGPointAdditions.h"
#include <math.h>

CGPoint CGPointAdd(CGPoint p0, CGPoint p1)
{
    return CGPointMake(p0.x + p1.x, p0.y + p1.y);
}

CGPoint CGPointSub(CGPoint p0, CGPoint p1)
{
    return CGPointMake(p0.x - p1.x, p0.y - p1.y);
}

CGFloat CGPointDot(CGPoint p0, CGPoint p1)
{
    return p0.x*p1.x + p0.y*p1.y;
}

CGFloat CGPointLength(CGPoint p)
{
    return sqrtf(CGPointLengthSq(p));
}

CGFloat CGPointLengthSq(CGPoint p)
{
    return CGPointDot(p, p);
}

CGPoint CGPointMul(CGPoint p, CGFloat s)
{
    return CGPointMake(p.x*s, p.y*s);
}