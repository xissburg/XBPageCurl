//
//  RootViewController_iPad.h
//  XBPageCurl
//
//  Created by xiss burg on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController_iPad : RootViewController {
    UIWebView *_webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
