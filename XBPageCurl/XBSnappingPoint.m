//
//  XBSnappingPoint.m
//  XBPageCurl
//
//  Created by xiss burg on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XBSnappingPoint.h"

@implementation XBSnappingPoint

@synthesize position, angle, radius, tag;

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: 0x%p> {\n\tposition = %@,\n\tangle = %f,\n\tradius = %f,\n\ttag = %d\n}", NSStringFromClass([self class]), self, NSStringFromCGPoint(position), angle, radius, tag];
}

@end
