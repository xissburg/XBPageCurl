//
//  SimpleCurlViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleCurlViewController.h"
#import "XBPageCurlView.h"

#define kDuration 0.6

@implementation SimpleCurlViewController

@synthesize messyView, pickerView, curlView, backView;

- (void)dealloc 
{
    self.messyView = nil;
    self.pickerView = nil;
    self.curlView = nil;
    self.backView = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messyView = nil;
    self.pickerView = nil;
    self.curlView = nil;
    self.backView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)curlButtonAction:(id)sender
{
    CGRect r = self.messyView.frame;
    self.curlView = [[[XBPageCurlView alloc] initWithFrame:r] autorelease];
    [self.curlView drawViewOnFrontOfPage:self.messyView];
    //[self.curlView drawImageOnNextPage:[UIImage imageNamed:@"appleStore"]];
    self.curlView.opaque = NO; //Transparency on the next page (so that the view behind curlView will appear)
    self.curlView.pageOpaque = YES; //The page to be curled has no transparency
    
    [self.curlView curlView:self.messyView cylinderPosition:CGPointMake(r.size.width/6, r.size.height/2) cylinderAngle:M_PI/2.4 cylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 160: 70 animatedWithDuration:kDuration];
}

- (IBAction)uncurlButtonAction:(id)sender
{
    [self.curlView uncurlAnimatedWithDuration:kDuration];
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return YES;
}

@end
