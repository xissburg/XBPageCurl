//
//  XBPageDragView.h
//  XBPageCurl
//
//  Created by xiss burg on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBPageCurlView.h"

@interface XBPageDragView : UIView <XBPageCurlViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *viewToCurl;
@property (nonatomic, readonly) BOOL pageIsCurled;

- (void)uncurlPageAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)refreshPageCurlView;

@end
