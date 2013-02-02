//
//  PageCurlViewController_iPad.h
//  XBPageCurl
//
//  Created by xiss burg on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageCurlViewController.h"

@interface PageCurlViewController_iPad : PageCurlViewController

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet XBPageCurlContainerView *pageCurlContainerView;

@end
