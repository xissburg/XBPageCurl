//
//  XBPageDragView.m
//  XBPageCurl
//
//  Created by xiss burg on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XBPageDragView.h"

@interface XBPageDragView ()

@property (nonatomic, retain) XBPageCurlView *pageCurlView;
@property (nonatomic, retain) XBSnappingPoint *bottomSnappingPoint;
@property (nonatomic, retain) XBSnappingPoint *curledSnappingPoint;
@property (strong,nonatomic) UIButton *uncurlButton;

@end

@implementation XBPageDragView

@synthesize viewToCurl = _viewToCurl;
@synthesize pageIsCurled = _pageIsCurled;
@synthesize pageCurlView = _pageCurlView;
@synthesize bottomSnappingPoint = _bottomSnappingPoint;
@synthesize curledSnappingPoint = _curledSnappingPoint;

- (void)dealloc
{
    [self.pageCurlView stopAnimating];
    self.viewToCurl = nil;
    self.pageCurlView = nil;
    self.bottomSnappingPoint = nil;
    [super dealloc];
}

#pragma mark - Properties

- (void)setViewToCurl:(UIView *)viewToCurl
{
    if (viewToCurl == _viewToCurl) {
        return;
    }
    
    [_viewToCurl release];
    _viewToCurl = [viewToCurl retain];
    
    [self.pageCurlView removeFromSuperview];
    self.pageCurlView = nil;
    
    if (_viewToCurl == nil) {
        return;
    }
    
    [self refreshPageCurlView];
}

#pragma mark - Methods
- (void)uncurlPageAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    NSTimeInterval duration = animated? 0.3: 0;
    [self.pageCurlView setCylinderPosition:self.bottomSnappingPoint.position animatedWithDuration:duration];
    [self.pageCurlView setCylinderAngle:self.bottomSnappingPoint.angle animatedWithDuration:duration];
    [self.pageCurlView setCylinderRadius:self.bottomSnappingPoint.radius animatedWithDuration:duration completion:^{
        self.hidden = NO;
        _pageIsCurled = NO;
        self.viewToCurl.hidden = NO;
        [self.pageCurlView removeFromSuperview];
        [self.uncurlButton removeFromSuperview];
        [self.pageCurlView stopAnimating];
        if (completion != nil) {
            completion();
        }
    }];
}

- (void)refreshPageCurlView
{
    [self.pageCurlView removeFromSuperview];
    self.pageCurlView = [[[XBPageCurlView alloc] initWithFrame:self.viewToCurl.frame] autorelease];
    self.pageCurlView.delegate = self;
    self.pageCurlView.pageOpaque = YES;
    self.pageCurlView.opaque = NO;
    self.pageCurlView.snappingEnabled = YES;
    
    XBSnappingPoint *point = [[[XBSnappingPoint alloc] init] autorelease];
    point.position = CGPointMake(self.viewToCurl.frame.size.width*0.875, self.viewToCurl.frame.size.height*0.06);
    point.angle = M_PI_4;
    point.radius = 30;
    [self.pageCurlView.snappingPoints addObject:point];
    self.bottomSnappingPoint = point;
    
    point = [[[XBSnappingPoint alloc] init] autorelease];
    point.position = CGPointMake(self.viewToCurl.frame.size.width*0.5, self.viewToCurl.frame.size.height*0.67);
    point.angle = M_PI/8;
    point.radius = 80;
    [self.pageCurlView.snappingPoints addObject:point];
    self.curledSnappingPoint = point;
    
    [self.pageCurlView drawViewOnFrontOfPage:self.viewToCurl];
}

-(void)uncurlTapped:(id)sender
{
    [self uncurlPageAnimated:YES completion:nil];
}

-(void)createUncurlButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(uncurlTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0,0,self.superview.frame.size.width, self.curledSnappingPoint.position.y);
    [self.superview addSubview:button];
    self.uncurlButton = button;
}
#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.viewToCurl.superview];
    
    if (CGRectContainsPoint(self.frame, touchLocation)) {
        self.hidden = YES;
        _pageIsCurled = YES;
        [self.pageCurlView drawViewOnFrontOfPage:self.viewToCurl];
        self.pageCurlView.cylinderPosition = self.bottomSnappingPoint.position;
        self.pageCurlView.cylinderAngle = self.bottomSnappingPoint.angle;
        self.pageCurlView.cylinderRadius = self.bottomSnappingPoint.radius;
        [self.pageCurlView touchBeganAtPoint:touchLocation];
        [self.viewToCurl.superview addSubview:self.pageCurlView];
        self.viewToCurl.hidden = YES;
        [self.pageCurlView startAnimating];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pageIsCurled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self.viewToCurl.superview];
        [self.pageCurlView touchMovedToPoint:touchLocation];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pageIsCurled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self.viewToCurl.superview];
        if (CGRectContainsPoint(self.frame, touchLocation)) {
            XBCurlView *cv = self.pageCurlView;
            XBSnappingPoint *sp = self.curledSnappingPoint;
            CGFloat duration = 0.3;
            [cv setCylinderPosition:sp.position animatedWithDuration:duration];
            [cv setCylinderRadius:sp.radius animatedWithDuration:duration];
            [cv setCylinderAngle:sp.angle animatedWithDuration:duration completion:^{
                [self createUncurlButton];
            }];
            _pageIsCurled = YES;
        } else {
            [self.pageCurlView touchEndedAtPoint:touchLocation];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.pageIsCurled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self.viewToCurl.superview];
        [self.pageCurlView touchEndedAtPoint:touchLocation];
    }
}

#pragma mark - XBPageCurlViewDelegate

- (void)pageCurlView:(XBPageCurlView *)pageCurlView didSnapToPoint:(XBSnappingPoint *)snappintPoint
{
    if (snappintPoint == self.bottomSnappingPoint) {
        self.hidden = NO;
        _pageIsCurled = NO;
        self.viewToCurl.hidden = NO;
        [self.pageCurlView removeFromSuperview];
        [self.pageCurlView stopAnimating];
    } else if (snappintPoint == self.curledSnappingPoint) {
        [self createUncurlButton];
    }
}

@end
