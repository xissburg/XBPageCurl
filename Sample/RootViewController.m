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
    self.curlView = [[[XBCurlView alloc] initWithFrame:r] autorelease];
    [self.curlView drawViewOnFrontOfPage:self.messyView];
    self.curlView.opaque = NO;
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
    CGRect frame = self.view.frame;
    double angle = M_PI/3;
    
    //Update the view drawn on the front of the curling page
    [self.curlView drawViewOnFrontOfPage:self.messyView];
    
    //Reset cylinder properties, positioning it on the right side, oriented vertically
    self.curlView.cylinderPosition = CGPointMake(frame.size.width, frame.size.height/2);
    self.curlView.cylinderAngle = M_PI_2;
    self.curlView.cylinderRadius = 20;
    
    //Start the cylinder animation
    [self.curlView setCylinderPosition:CGPointMake(frame.size.width/6, frame.size.height/2) animatedWithDuration:kDuration];
    [self.curlView setCylinderAngle:angle animatedWithDuration:kDuration];
    [self.curlView setCylinderRadius:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? 160: 70 animatedWithDuration:kDuration];
    
    //Allow interaction with back view
    self.curlView.userInteractionEnabled = NO;
    
    //Setup the view hierarchy properly
    [self.view addSubview:self.curlView];
    [self.messyView removeFromSuperview];
    
    //Start the rendering loop
    [self.curlView startAnimating];
}

- (IBAction)uncurlButtonAction:(id)sender
{
    CGRect frame = self.view.frame;
    
    //Animate the cylinder back to its start position at the right side of the screen, oriented vertically
    [self.curlView setCylinderPosition:CGPointMake(frame.size.width, frame.size.height/2) animatedWithDuration:kDuration];
    [self.curlView setCylinderAngle:M_PI_2 animatedWithDuration:kDuration];
    [self.curlView setCylinderRadius:20 animatedWithDuration:kDuration completion:^(void) {
        //Setup the view hierarchy properly after the animation is finished
        [self.view addSubview:self.messyView];
        [self.curlView removeFromSuperview];
        //Stop the rendering loop since the curlView won't appear at the moment
        [self.curlView stopAnimating];
    }];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    return YES;
}

@end
