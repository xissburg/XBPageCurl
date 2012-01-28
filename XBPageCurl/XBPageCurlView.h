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
- (void)pageCurlView:(XBPageCurlView *)pageCurlView willSnapToPoint:(XBSnappingPoint *)snappintPoint;
- (void)pageCurlView:(XBPageCurlView *)pageCurlView didSnapToPoint:(XBSnappingPoint *)snappintPoint;

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

@end
