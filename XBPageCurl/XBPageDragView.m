//
//  XBPageDragView.m
//  XBPageCurl
//
//  Created by xiss burg on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "XBPageDragView.h"

@interface XBPageDragView ()

@property (nonatomic, readwrite) BOOL pageIsCurled;
@property (nonatomic) XBPageCurlView *pageCurlView;
@property (nonatomic) XBSnappingPoint *bottomSnappingPoint;

@end

@implementation XBPageDragView

- (void)dealloc
{
    [self.pageCurlView stopAnimating];
    self.viewToCurl = nil;
    self.pageCurlView = nil;
    self.bottomSnappingPoint = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self != nil) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
}

#pragma mark - Properties

- (void)setViewToCurl:(UIView *)viewToCurl
{
    if (viewToCurl == _viewToCurl) {
        return;
    }
    
    _viewToCurl = viewToCurl;
    
    [self.pageCurlView removeFromSuperview];
    self.pageCurlView = nil;
    
    if (_viewToCurl == nil) {
        return;
    }
    
    [self refreshPageCurlView];
}

- (BOOL)pageIsCurled {
    return _pageIsCurled;
}

#pragma mark - Methods

- (void)uncurlPageAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    NSTimeInterval duration = animated? 0.3: 0;
    [self.pageCurlView setCylinderPosition:self.bottomSnappingPoint.position animatedWithDuration:duration];
    [self.pageCurlView setCylinderAngle:self.bottomSnappingPoint.angle animatedWithDuration:duration];
    
    XBPageDragView __weak *_self = self;
    [self.pageCurlView setCylinderRadius:self.bottomSnappingPoint.radius animatedWithDuration:duration completion:^{
        XBPageDragView * blockSelf = _self;
        blockSelf.hidden = NO;
        blockSelf.pageIsCurled= NO;
        blockSelf.viewToCurl.hidden = NO;
        [blockSelf.pageCurlView removeFromSuperview];
        [blockSelf.pageCurlView stopAnimating];
        if (completion != nil) {
            completion();
        }
    }];
}

- (void)refreshPageCurlView
{
    [self.pageCurlView removeFromSuperview];
    self.pageCurlView = [[XBPageCurlView alloc] initWithFrame:self.viewToCurl.frame];
    self.pageCurlView.delegate = self;
    self.pageCurlView.pageOpaque = YES;
    self.pageCurlView.opaque = NO;
    self.pageCurlView.snappingEnabled = YES;
    
    XBSnappingPoint *point = [[XBSnappingPoint alloc] init];
    point.position = CGPointMake(self.viewToCurl.frame.size.width*0.875, self.viewToCurl.frame.size.height*0.06);
    point.angle = M_PI_4;
    point.radius = 30;
    [self.pageCurlView.snappingPoints addObject:point];
    self.bottomSnappingPoint = point;
    
    point = [[XBSnappingPoint alloc] init];
    point.position = CGPointMake(self.viewToCurl.frame.size.width*0.5, self.viewToCurl.frame.size.height*0.67);
    point.angle = M_PI/8;
    point.radius = 80;
    [self.pageCurlView.snappingPoints addObject:point];
    
    [self.pageCurlView drawViewOnFrontOfPage:self.viewToCurl];
}

#pragma mark - Touches

- (void)beginCurlWithTouchAt:(CGPoint)point {
    CGFloat angle = M_PI_4;
//    if (point.x < (self.frame.size.width/2)) {
        angle = (2*M_PI)-M_PI_2;
//    }
    [self beginCurlingWithCylinderAtPoint:point /* need to offset this to cylinder center? */
        angle:angle
        radius:self.bottomSnappingPoint.radius];
}

- (void)updateCurlWithTouchAt:(CGPoint)point {
    if (self.pageIsCurled) {
        [self.pageCurlView moveCurlToPoint:point];
    }
}

- (void)endCurlWithTouchAt:(CGPoint)point {
    if (self.pageIsCurled) {
        [self.pageCurlView endCurlingAtPoint:point];
    }
}

- (void)beginCurlingWithCylinderAtPoint:(CGPoint)point angle:(CGFloat)angle radius:(CGFloat)radius {
    self.hidden = YES;
    _pageIsCurled = YES;
    [self.pageCurlView drawViewOnFrontOfPage:self.viewToCurl];
    self.pageCurlView.cylinderPosition = point;
    self.pageCurlView.cylinderAngle = angle;
    self.pageCurlView.cylinderRadius = radius;

    [self.pageCurlView beginCurlingAtPoint:point];
    
    // Monkey the view hierarchy
    [self.viewToCurl.superview addSubview:self.pageCurlView];
    self.viewToCurl.hidden = YES;

    // Start the rendering
    [self.pageCurlView startAnimating];
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
    }
}

@end
