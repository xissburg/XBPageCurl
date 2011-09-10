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

@synthesize messyView, pickerView, curlView;

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
    self.curlView = [[[XBCurlView alloc] initWithFrame:r] autorelease];
    [self.curlView drawViewOnTexture:self.messyView];
    self.curlView.opaque = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messyView = nil;
    self.pickerView = nil;
    self.curlView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)hehButtonAction:(id)sender
{
    double angle = M_PI/2.5;
    [self.curlView drawViewOnTexture:self.messyView];
    [self.curlView startAnimating];
    self.curlView.cylinderPosition = CGPointMake(320, 240);
    [self.curlView setCylinderPosition:CGPointMake(30, 240) animatedWithDuration:kDuration];
    [self.curlView setCylinderDirection:CGPointMake(cos(angle), sin(angle)) animatedWithDuration:kDuration];
    [self.curlView setCylinderRadius:70 animatedWithDuration:kDuration];
    self.curlView.userInteractionEnabled = NO; //Allow interaction with back view
    [self.view addSubview:self.curlView];
    [self.messyView removeFromSuperview];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.curlView setCylinderPosition:CGPointMake(320, 240) animatedWithDuration:kDuration];
    [self.curlView setCylinderDirection:CGPointMake(0,1) animatedWithDuration:kDuration];
    [self.curlView setCylinderRadius:20 animatedWithDuration:kDuration completion:^(void) {
        [self.view addSubview:self.messyView];
        [self.curlView removeFromSuperview];
        [self.curlView stopAnimating];
    }];
}

@end
