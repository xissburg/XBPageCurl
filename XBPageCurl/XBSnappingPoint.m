//
//  XBSnappingPoint.m
//  XBPageCurl
//
//  Created by xiss burg on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "XBSnappingPoint.h"

@implementation XBSnappingPoint

- (id)initWithPosition:(CGPoint)position angle:(CGFloat)angle radius:(CGFloat)radius {
    id _self = [super init];
    if (_self != nil) {
        _position = position;
        _angle = angle;
        _radius = radius;
    }
    return _self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: 0x%p> {\n\tposition = %@,\n\tangle = %f,\n\tradius = %f,\n\ttag = %d\n}",
        NSStringFromClass([self class]), self, NSStringFromCGPoint(_position), _angle, _radius, _tag];
}

@end
