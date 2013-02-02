//
//  XBPageCurlContainerView.m
//  XBPageCurl
//
//  Created by Marc Palmer on 13/01/2013.
//
//

#import "XBPageCurlContainerView.h"

@interface XBPageCurlContainerView () {
@private
    NSMutableArray *snappingPoints;
}

@property (nonatomic) BOOL pageIsCurled;
@property (nonatomic) XBPageCurlView *pageCurlView;
@property (nonatomic) XBSnappingPoint *bottomSnappingPoint;
@property (nonatomic) IBOutlet UIView *viewToCurl;

@end

@implementation XBPageCurlContainerView

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
        self.pageOpaque = NO;
        self.snappingEnabled = YES;
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
    snappingPoints = [NSMutableArray new];
    if ([self.subviews count]) {
        self.opaque = NO;
        self.viewToCurl = self.subviews[0];
    }
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
    
    XBPageCurlContainerView __weak *_self = self;
    [self.pageCurlView setCylinderRadius:self.bottomSnappingPoint.radius animatedWithDuration:duration completion:^{
        XBPageCurlContainerView * blockSelf = _self;
        if (blockSelf) {
            NSLog(@"Showing original view in uncurl");
            blockSelf.pageIsCurled= NO;
            blockSelf.viewToCurl.hidden = NO;
            [blockSelf.pageCurlView removeFromSuperview]; // @todo can we just hide it?
            [blockSelf.pageCurlView stopAnimating];
        }
        if (completion != nil) {
            completion();
        }
    }];
}

- (void)refreshPageCurlView {
    NSLog(@"Refreshing page curl view");
    [self resetPageCurlView];
    [self redrawPageCurlView];
}

- (void)redrawPageCurlView {
    NSLog(@"Redrawing view to curl");
    if (self.pageCurlView == nil) {
        [self resetPageCurlView];
    }
    [self.pageCurlView drawViewOnFrontOfPage:self.viewToCurl];
}

- (void)resetPageCurlView
{
    NSLog(@"Resetting page curl view");
    [self.pageCurlView removeFromSuperview];
    self.pageCurlView = [[XBPageCurlView alloc] initWithFrame:self.viewToCurl.frame];
    self.pageCurlView.delegate = self;

    // Monkey the view hierarchy
    [self addSubview:self.pageCurlView];
    self.pageCurlView.hidden = YES;

    [self prepare];
}

- (void)addSnappingPointWithPosition:(CGPoint)position angle:(CGFloat)angle radius:(CGFloat)radius {
    [snappingPoints addObject:[[XBSnappingPoint alloc] initWithPosition:position angle:angle radius:radius]];
}

- (void)clearSnappingPoints {
    [snappingPoints removeAllObjects];
}

- (void)prepare {
    self.pageCurlView.pageOpaque = self.pageOpaque;
    self.pageCurlView.opaque = NO;
    self.pageCurlView.snappingEnabled = self.snappingEnabled;
    self.pageCurlView.curlAngleMode = self.curlAngleMode;
    self.pageCurlView.initialCurlAngleMode = self.initialCurlAngleMode;

    
    for (XBSnappingPoint *p in snappingPoints) {
        [self.pageCurlView.snappingPoints addObject:p];
    }
}


#pragma mark - Curl lifecycle

- (void)beginCurlWithTouchAt:(CGPoint)point {
    [self redrawPageCurlView];
    [self beginCurlingWithCylinderAtPoint:point /* need to offset this to cylinder center? */
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
    NSLog(@"Showing original view in endCurlWith");
    self.viewToCurl.hidden = NO;
    NSLog(@"Hiding curl view in endCurlWith");
    self.pageCurlView.hidden = YES;
    _pageIsCurled = NO;
}

#pragma mark - Internals

- (void)beginCurlingWithCylinderAtPoint:(CGPoint)point radius:(CGFloat)radius {
    _pageIsCurled = YES;

//    self.pageCurlView.cylinderPosition = point;
    self.pageCurlView.cylinderRadius = radius;

    [self.pageCurlView beginCurlingAtPoint:point];
    
//    NSLog(@"Hiding original view in beingCurling");
//    self.viewToCurl.hidden = YES;
    NSLog(@"Showing curl view in beingCurling");
    self.pageCurlView.hidden = NO;

    // Start the rendering
    [self.pageCurlView startAnimating];
}

#pragma mark - XBPageCurlViewDelegate

- (void)pageCurlView:(XBPageCurlView *)pageCurlView didSnapToPoint:(XBSnappingPoint *)snappintPoint
{
    if (snappintPoint == self.bottomSnappingPoint) {
        _pageIsCurled = NO;
        NSLog(@"Showing original view");
        self.viewToCurl.hidden = NO;
        [self.pageCurlView removeFromSuperview];
        [self.pageCurlView stopAnimating];
    }
}

- (CGFloat)pageCurlView:(XBPageCurlView *)pageCurlView angleForPoint:(CGPoint)cylinderPoint {
    // @todo remove this
    return pageCurlView.initialAngle;
}



@end
