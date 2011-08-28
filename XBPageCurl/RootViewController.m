//
//  RootViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "XBPageCurlView.h"

@implementation RootViewController

@synthesize messyView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.messyView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    XBPageCurlView *pageCurlView = [[[XBPageCurlView alloc] initWithView:self.messyView] autorelease];
    [self.view addSubview:pageCurlView];
    self.messyView.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messyView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
