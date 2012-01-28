//
//  XBSnappingPoint.h
//  XBPageCurl
//
//  Created by xiss burg on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBSnappingPoint : NSObject

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) int tag;

@end
