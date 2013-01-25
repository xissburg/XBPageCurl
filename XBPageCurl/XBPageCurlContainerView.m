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

@property (nonatomic, readwrite) BOOL pageIsCurled;
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
        self.pageOpaque = YES;
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
    [self resetPageCurlView];
    [self redrawPageCurlView];
}

- (void)redrawPageCurlView {
    [self.pageCurlView drawViewOnFrontOfPage:self.viewToCurl];
}

- (void)resetPageCurlView
{
    [self.pageCurlView removeFromSuperview];
    self.pageCurlView = [[XBPageCurlView alloc] initWithFrame:self.viewToCurl.frame];
    self.pageCurlView.delegate = self;

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
    
    for (XBSnappingPoint *p in snappingPoints) {
        [self.pageCurlView.snappingPoints addObject:p];
    }
}


#pragma mark - Curl lifecycle

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

#pragma mark - Internals

- (void)beginCurlingWithCylinderAtPoint:(CGPoint)point angle:(CGFloat)angle radius:(CGFloat)radius {
    _pageIsCurled = YES;

    [self redrawPageCurlView];

    self.pageCurlView.cylinderPosition = point;
    self.pageCurlView.cylinderAngle = angle;
    self.pageCurlView.cylinderRadius = radius;

    [self.pageCurlView beginCurlingAtPoint:point];
    
    // Monkey the view hierarchy
    [self addSubview:self.pageCurlView];
    
    // @todo parameterise this
    self.viewToCurl.hidden = YES;

    // Start the rendering
    [self.pageCurlView startAnimating];
}

#pragma mark - XBPageCurlViewDelegate

- (void)pageCurlView:(XBPageCurlView *)pageCurlView didSnapToPoint:(XBSnappingPoint *)snappintPoint
{
    if (snappintPoint == self.bottomSnappingPoint) {
        _pageIsCurled = NO;
        self.viewToCurl.hidden = NO;
        [self.pageCurlView removeFromSuperview];
        [self.pageCurlView stopAnimating];
    }
}

@end
