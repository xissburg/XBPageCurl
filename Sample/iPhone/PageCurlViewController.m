//
//  PageCurlViewController.m
//  XBPageCurl
//
//  Created by xiss burg on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageCurlViewController.h"

#define kDuration 0.3

@implementation PageCurlViewController

@synthesize curlImage = _curlImage;
@synthesize frontView = _frontView;
@synthesize backView = _backView;
@synthesize pageCurlView = _pageCurlView;
@synthesize pageIsCurled, bottomSnappingPoint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
    self.curlImage = nil;
    self.frontView = nil;
    self.backView = nil;
    self.pageCurlView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageCurlView = [[[XBPageCurlView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];
    [self.view addSubview:self.pageCurlView];
    self.pageCurlView.delegate = self;
    self.pageCurlView.hidden = YES;
    self.pageCurlView.pageOpaque = YES;
    self.pageCurlView.opaque = NO;
    self.pageCurlView.snappingEnabled = YES;
    
    XBSnappingPoint *point = [[[XBSnappingPoint alloc] init] autorelease];
    point.position = CGPointMake(280, 25);
    point.angle = M_PI_4;
    point.radius = 20;
    [self.pageCurlView.snappingPoints addObject:point];
    self.bottomSnappingPoint = point;
    
    point = [[[XBSnappingPoint alloc] init] autorelease];
    point.position = CGPointMake(160, 220);
    point.angle = M_PI/7;
    point.radius = 60;
    [self.pageCurlView.snappingPoints addObject:point];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.curlImage = nil;
    self.frontView = nil;
    self.backView = nil;
    self.pageCurlView = nil;
    self.bottomSnappingPoint = nil;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(self.curlImage.frame, touchLocation)) {
        self.curlImage.hidden = YES;
        self.pageIsCurled = YES;
        [self.pageCurlView drawViewOnFrontOfPage:self.frontView];
        self.pageCurlView.cylinderPosition =self.bottomSnappingPoint.position;
        self.pageCurlView.cylinderAngle = self.bottomSnappingPoint.angle;
        self.pageCurlView.cylinderRadius = self.bottomSnappingPoint.radius;
        self.pageCurlView.hidden = NO;
        self.frontView.hidden = YES;
        [self.pageCurlView startAnimating];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pageIsCurled) {
        [self.pageCurlView touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pageIsCurled) {
        [self.pageCurlView touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pageIsCurled) {
        [self.pageCurlView touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - XBPageCurlViewDelegate

- (void)pageCurlView:(XBPageCurlView *)pageCurlView didSnapToPoint:(XBSnappingPoint *)snappintPoint
{
    if (snappintPoint == self.bottomSnappingPoint) {
        self.curlImage.hidden = NO;
        self.pageIsCurled = NO;
        self.frontView.hidden = NO;
        self.pageCurlView.hidden = YES;
        [self.pageCurlView stopAnimating];
    }
}

#pragma mark - Buttons Actions

- (IBAction)buttonAction:(id)sender
{
    if (self.pageIsCurled) {
        [self.pageCurlView setCylinderPosition:self.bottomSnappingPoint.position animatedWithDuration:kDuration];
        [self.pageCurlView setCylinderAngle:self.bottomSnappingPoint.angle animatedWithDuration:kDuration];
        [self.pageCurlView setCylinderRadius:self.bottomSnappingPoint.radius animatedWithDuration:kDuration completion:^{
            self.curlImage.hidden = NO;
            self.pageIsCurled = NO;
            self.frontView.hidden = NO;
            self.pageCurlView.hidden = YES;
            [self.pageCurlView stopAnimating];
        }];
    }
}

- (IBAction)backButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
