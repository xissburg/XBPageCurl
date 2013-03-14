//
//  XBPageCurlView.h
//  XBPageCurl
//
//  Created by xiss burg on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBCurlView.h"
#import "XBSnappingPoint.h"

@class XBPageCurlView;

@protocol XBPageCurlViewDelegate <NSObject>

@optional
- (void)pageCurlView:(XBPageCurlView *)pageCurlView willSnapToPoint:(XBSnappingPoint *)snappingPoint;
- (void)pageCurlView:(XBPageCurlView *)pageCurlView didSnapToPoint:(XBSnappingPoint *)snappingPoint;

@end

/**
 * XBPageCurlView
 * Adds user interaction to XBCurlView. Allows the user to drag the page with his finger and also supports the placement of 
 * snapping points that the cylinder will stick to after the user releases his finger off the screen.
 */
@interface XBPageCurlView : XBCurlView

@property (nonatomic, assign) id<XBPageCurlViewDelegate> delegate;
@property (nonatomic, assign) BOOL snappingEnabled;
@property (nonatomic, assign) CGFloat minimumCylinderAngle;
@property (nonatomic, assign) CGFloat maximumCylinderAngle;
@property (nonatomic, readonly) NSArray *snappingPoints;

- (void)touchBeganAtPoint:(CGPoint)p;
- (void)touchMovedToPoint:(CGPoint)p;
- (void)touchEndedAtPoint:(CGPoint)p;
- (void)addSnappingPoint:(XBSnappingPoint *)snappingPoint;
- (void)addSnappingPointsFromArray:(NSArray *)snappingPoints;
- (void)removeSnappingPoint:(XBSnappingPoint *)snappingPoint;

@end
