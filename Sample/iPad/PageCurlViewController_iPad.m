//
//  PageCurlViewController_iPad.m
//  XBPageCurl
//
//  Created by xiss burg on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageCurlViewController_iPad.h"

@implementation PageCurlViewController_iPad

@synthesize webView = _webView;

- (void)dealloc
{
    self.webView = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xissburg.com"]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

@end
