//
//  RootViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "XBPageCurlView.h"

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
    self.curlView = [[[XBPageCurlView alloc] initWithFrame:r] autorelease];
    [self.curlView drawViewOnFrontOfPage:self.messyView];
    [self.curlView drawViewOnNextPage:self.backView];
    self.curlView.opaque = NO;
    //self.curlView.pageOpaque = NO;
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
    CGRect frame = self.curlView.frame;
    
    [self.curlView curlView:self.messyView cylinderPosition:CGPointMake(frame.size.width/6, frame.size.height/2) cylinderAngle:M_PI/2.3 cylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 160: 70 animatedWithDuration:kDuration];
}

- (IBAction)uncurlButtonAction:(id)sender
{
    [self.curlView uncurlAnimatedWithDuration:kDuration];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return YES;
}

@end
