//
//  PageCurlViewController.h
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBPageCurlView.h"

@interface PageCurlViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIButton *curlButton;
@property (nonatomic, retain) XBPageCurlView *pageCurlView;

- (IBAction)buttonAction:(id)sender;
- (IBAction)curlButtonTouchDown:(id)sender;

@end
