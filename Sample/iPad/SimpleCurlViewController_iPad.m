//
//  SimpleCurlViewController_iPad.m
//  XBPageCurl
//
//  Created by xiss burg on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleCurlViewController_iPad.h"

@implementation SimpleCurlViewController_iPad

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
