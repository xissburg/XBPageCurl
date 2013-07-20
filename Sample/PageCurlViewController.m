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

- (void)viewDidLoad
{
    [super viewDidLoad];
    XBSnappingPoint *point = [[XBSnappingPoint alloc] initWithPosition:CGPointMake(self.pageDragBottomRightView.viewToCurl.frame.size.width*0.5, self.pageDragBottomRightView.viewToCurl.frame.size.height*0.4) angle:7*M_PI/8 radius:80 weight:0.5];
    [self.pageDragBottomRightView.pageCurlView addSnappingPoint:point];
    
    point = [[XBSnappingPoint alloc] initWithPosition:CGPointMake(self.pageDragTopLeftView.viewToCurl.frame.size.width*0.5, self.pageDragTopLeftView.viewToCurl.frame.size.height*0.6) angle:-M_PI/6 radius:70 weight:0.5];
    [self.pageDragTopLeftView.pageCurlView addSnappingPoint:point];
    
    self.pageDragTopLeftView.cornerSnappingPoint.position = CGPointZero;
    self.pageDragTopLeftView.cornerSnappingPoint.angle = -M_PI_4;
}

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
    [self.pageDragTopLeftView refreshPageCurlView];
    [self.pageDragBottomRightView refreshPageCurlView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return !self.pageDragBottomRightView.pageIsCurled && !self.pageDragTopLeftView.pageIsCurled;
}

- (BOOL)shouldAutorotate
{
    return !self.pageDragBottomRightView.pageIsCurled && !self.pageDragTopLeftView.pageIsCurled;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // After a rotation we have to reset the viewToCurl for the curling mesh to be updated.
    [self.pageDragTopLeftView refreshPageCurlView];
    [self.pageDragBottomRightView refreshPageCurlView];
}

#pragma mark - Buttons Actions

- (IBAction)buttonAction:(id)sender
{
    if (self.pageDragTopLeftView.pageIsCurled) {
        [self.pageDragTopLeftView uncurlPageAnimated:YES completion:nil];
    }
    else if (self.pageDragBottomRightView.pageIsCurled) {
        [self.pageDragBottomRightView uncurlPageAnimated:YES completion:nil];
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
    UIImage *image = nil;
    if (self.pageDragTopLeftView.pageIsCurled) {
        image = [self.pageDragTopLeftView.pageCurlView imageFromFramebufferWithBackgroundView:self.backView];
    }
    else if (self.pageDragBottomRightView.pageIsCurled) {
        image = [self.pageDragBottomRightView.pageCurlView imageFromFramebufferWithBackgroundView:self.backView];
    }
    
    // Force it to save a high quality PNG instead of a lossy JPEG
    NSData *data = UIImagePNGRepresentation(image);
    image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
}

@end
