//
//  XBPageCurlContainerView.h
//  XBPageCurl
//
//  Created by Marc Palmer on 13/01/2013.
//
//

#import <UIKit/UIKit.h>
#import "XBPageCurlView.h"

@interface XBPageCurlContainerView : UIView <XBPageCurlViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) BOOL pageIsCurled;

- (void)uncurlPageAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)refreshPageCurlView;

- (void)beginCurlWithTouchAt:(CGPoint)point;
- (void)updateCurlWithTouchAt:(CGPoint)point;
- (void)endCurlWithTouchAt:(CGPoint)point;

@end
