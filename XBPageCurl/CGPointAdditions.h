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

#endif
