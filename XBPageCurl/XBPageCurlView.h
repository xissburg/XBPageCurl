//
//  XBPageCurlView.h
//  XBPageCurl
//
//  Created by xiss burg on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBCurlView.h"


@class XBPageCurlView;

typedef enum {
    XBNone,
    XBNext,
    XBPrevious
} XBDirection;


@protocol XBPageCurlViewDelegate <NSObject>

- (void)pageCurlView:(XBPageCurlView *)pageCurlView willFlipToDirection:(XBDirection)direction;
- (void)pageCurlView:(XBPageCurlView *)pageCurlView didFlipToDirection:(XBDirection)direction;
- (void)pageCurlView:(XBPageCurlView *)pageCurlView didCancelFlipToDirection:(XBDirection)direction;

@end


@interface XBPageCurlView : XBCurlView {
    CGPoint startPickingPosition;
}

@property (nonatomic, assign) id<XBPageCurlViewDelegate> delegate;

@end
