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

typedef enum {
    XBCurlAngleUpdateModeFollow,
    XBCurlAngleUpdateModeDelegate
} XBPageCurlUpdateAngleMode;

typedef enum {
    XBCurlAngleInitialModeFromTop =     0x01,
    XBCurlAngleInitialModeFromBottom =  0x02,
    XBCurlAngleInitialModeFromLeft =    0x04,
    XBCurlAngleInitialModeFromRight =   0x08
} XBPageCurlInitialAngleMode;

@protocol XBPageCurlViewDelegate <NSObject>

@optional
- (void)pageCurlView:(XBPageCurlView *)pageCurlView willSnapToPoint:(XBSnappingPoint *)snappintPoint;
- (void)pageCurlView:(XBPageCurlView *)pageCurlView didSnapToPoint:(XBSnappingPoint *)snappintPoint;
- (CGFloat)pageCurlView:(XBPageCurlView *)pageCurlView angleForPoint:(CGPoint)cylinderPoint;

@end

/**
 * XBPageCurlView
 * Adds user interaction to XBCurlView. Allows the user to drag the page with his finger and also supports the placement of 
 * snapping points that the cylinder will stick to after the user releases his finger off the screen.
 */
@interface XBPageCurlView : XBCurlView {
    CGPoint startPickingPosition;
}

@property (nonatomic, assign) id<XBPageCurlViewDelegate> delegate;
@property (nonatomic, assign) BOOL snappingEnabled;
@property (nonatomic, retain) NSMutableArray *snappingPoints;
@property (nonatomic, assign) XBPageCurlUpdateAngleMode curlAngleMode;
@property (nonatomic, assign) XBPageCurlInitialAngleMode initialCurlAngleMode;
@property (nonatomic, assign) XBPageCurlInitialAngleMode activeCurlAngleMode;
@property (nonatomic, readonly) CGFloat initialAngle;


- (void)beginCurlingAtPoint:(CGPoint)p;
- (void)moveCurlToPoint:(CGPoint)p;
- (void)endCurlingAtPoint:(CGPoint)p;

@end
