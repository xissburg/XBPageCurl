//
//  RootViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#define kDuration 0.6

@implementation RootViewController

@synthesize messyView, pickerView, curlView, backView;

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
    self.pickerView = nil;
    self.curlView = nil;
    self.backView = nil;
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
    
    CGRect r = CGRectZero;
    r.size = self.view.bounds.size;
    self.curlView = [[[XBCurlView alloc] initWithFrame:r horizontalResolution:(NSUInteger)(r.size.width/10) verticalResolution:(NSUInteger)(r.size.height/10) antialiasing:NO] autorelease];
    [self.curlView drawViewOnFrontOfPage:self.messyView];
    [self.curlView drawViewOnNextPage:self.backView];
    //self.curlView.opaque = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messyView = nil;
    self.pickerView = nil;
    self.curlView = nil;
    self.backView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)curlButtonAction:(id)sender
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    double angle = M_PI/2.5;
    [self.curlView drawViewOnFrontOfPage:self.messyView];
    [self.curlView drawViewOnNextPage:self.backView];
    [self.curlView startAnimating];
    self.curlView.cylinderPosition = CGPointMake(appFrame.size.width, appFrame.size.height/2);
    self.curlView.cylinderDirection = CGPointMake(0, 1);
    [self.curlView setCylinderPosition:CGPointMake(appFrame.size.width/6, appFrame.size.height/2) animatedWithDuration:kDuration];
    [self.curlView setCylinderDirection:CGPointMake(cos(angle), sin(angle)) animatedWithDuration:kDuration];
    [self.curlView setCylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 160: 70 animatedWithDuration:kDuration];
    self.curlView.userInteractionEnabled = NO; //Allow interaction with back view
    [self.view addSubview:self.curlView];
    //[self.messyView removeFromSuperview];
}

- (IBAction)uncurlButtonAction:(id)sender
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    [self.curlView setCylinderPosition:CGPointMake(appFrame.size.width, appFrame.size.height/2) animatedWithDuration:kDuration];
    [self.curlView setCylinderDirection:CGPointMake(0,1) animatedWithDuration:kDuration];
    [self.curlView setCylinderRadius:20 animatedWithDuration:kDuration completion:^(void) {
        //[self.view addSubview:self.messyView];
        [self.curlView removeFromSuperview];
        [self.curlView stopAnimating];
    }];
}

@end
