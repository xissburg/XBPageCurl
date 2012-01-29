//
//  PageCurlViewController.h
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBPageCurlView.h"

@interface PageCurlViewController : UIViewController <XBPageCurlViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *frontView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIImageView *curlImage;
@property (nonatomic, retain) XBPageCurlView *pageCurlView;
@property (nonatomic, assign) BOOL pageIsCurled;
@property (nonatomic, assign) XBSnappingPoint *bottomSnappingPoint;

- (IBAction)buttonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@end
