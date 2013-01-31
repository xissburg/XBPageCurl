//
//  PageCurlViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageCurlViewController.h"
#import "XBPageCurlContainerView.h"
#import <QuartzCore/QuartzCore.h>

#define kDuration 0.3

@interface PageCurlViewController () {
@private
    UIPanGestureRecognizer *panGestureRecognizer;
}

@end

@implementation PageCurlViewController

- (void)dealloc
{
    self.mapView = nil;
    self.frontView = nil;
    self.backView = nil;
    self.pageCurlContainerView = nil;
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mapView = nil;
    self.frontView = nil;
    self.backView = nil;
    self.pageCurlContainerView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (panGestureRecognizer == nil) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
            action:@selector(panGestureRecognizerUpdated:)];
        [self.view addGestureRecognizer:panGestureRecognizer];
    }

    self.pageCurlContainerView.snappingEnabled = YES;
    self.pageCurlContainerView.pageOpaque = NO;
//    self.pageCurlContainerView.curlAngleMode = XBCurlAngleUpdateModeDelegate;
    self.pageCurlContainerView.initialCurlAngleMode = XBCurlAngleInitialModeFromLeft | XBCurlAngleInitialModeFromRight;
    
    [self.pageCurlContainerView clearSnappingPoints];
    [self.pageCurlContainerView addSnappingPointWithPosition:
        CGPointMake(self.view.bounds.size.width*2, self.view.bounds.size.height)
        angle:M_PI radius:60.0f];
    [self.pageCurlContainerView prepare];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // If the viewController was pushed in a landscape orientation its frame was that of a portrait view yet, then we have to reset the
    // page curl view's mesh here.
//    [self.pageCurlContainerView refreshPageCurlView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return !self.pageCurlContainerView.pageIsCurled;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // After a rotation we have to reset the viewToCurl for the curling mesh to be updated.
    [self.pageCurlContainerView refreshPageCurlView];
}

#pragma marc - Gestures

- (void)panGestureRecognizerUpdated:(UIPanGestureRecognizer *)recognizer {
    UIView *viewForPanning = ((XBPageCurlContainerView *)recognizer.view);
    CGPoint point = [recognizer locationInView:viewForPanning];

    if (!self.pageCurlContainerView.pageIsCurled) {
        [self.pageCurlContainerView beginCurlWithTouchAt:point];
    } else {
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self.pageCurlContainerView endCurlWithTouchAt:point];
        } else {
            [self.pageCurlContainerView updateCurlWithTouchAt:point];
        }
    }
}


#pragma mark - Buttons Actions

- (IBAction)buttonAction:(id)sender
{
    if (self.pageCurlContainerView.pageIsCurled) {
        [self.pageCurlContainerView uncurlPageAnimated:YES completion:nil];
    }
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)standardButtonAction:(id)sender
{
    self.mapView.mapType = MKMapTypeStandard;
}

- (void)satelliteButtonAction:(id)sender
{
    self.mapView.mapType = MKMapTypeSatellite;
}

- (void)hybridButtonAction:(id)sender
{
    self.mapView.mapType = MKMapTypeHybrid;
}

- (void)saveImageButtonAction:(id)sender
{
/*
    UIImage *image = [self.pageCurlContainerView.pageCurlView imageFromFramebufferWithBackgroundView:self.backView];
    // Force it to save a high quality PNG instead of a lossy JPEG
    NSData *data = UIImagePNGRepresentation(image);
    image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
*/
}

@end
