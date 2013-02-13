//
//  PageCurlViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageCurlViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kDuration 0.3

@implementation PageCurlViewController

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // If the viewController was pushed in a landscape orientation its frame was that of a portrait view yet, then we have to reset the
    // page curl view's mesh here.
    [self.pageDragView refreshPageCurlView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return !self.pageDragView.pageIsCurled;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // After a rotation we have to reset the viewToCurl for the curling mesh to be updated.
    [self.pageDragView refreshPageCurlView];
}

#pragma mark - Buttons Actions

- (IBAction)buttonAction:(id)sender
{
    if (self.pageDragView.pageIsCurled) {
        [self.pageDragView uncurlPageAnimated:YES completion:nil];
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
    UIImage *image = [self.pageDragView.pageCurlView imageFromFramebufferWithBackgroundView:self.backView];
    // Force it to save a high quality PNG instead of a lossy JPEG
    NSData *data = UIImagePNGRepresentation(image);
    image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
}

@end
