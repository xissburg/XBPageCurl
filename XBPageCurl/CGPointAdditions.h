//
//  CGPointAdditions.h
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef XBPageCurl_CGPointAdditions_h
#define XBPageCurl_CGPointAdditions_h

#include <CoreGraphics/CGGeometry.h>

CGPoint CGPointAdd(CGPoint p0, CGPoint p1);
CGPoint CGPointSub(CGPoint p0, CGPoint p1);
CGFloat CGPointDot(CGPoint p0, CGPoint p1);
CGFloat CGPointLength(CGPoint p);
CGFloat CGPointLengthSq(CGPoint p);
CGPoint CGPointMul(CGPoint p, CGFloat s);

/**
 * Returns the distance between the point p and the line with direction v (not necessarily normalized) and containing the point q.
 */
CGFloat CGPointToLineDistance(CGPoint p, CGPoint q, CGPoint v);
CGFloat CGPointToLineDistanceSq(CGPoint p, CGPoint q, CGPoint v);

#endif
