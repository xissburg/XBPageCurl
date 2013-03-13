//
//  XBPage.h
//  XBPageCurl
//
//  Created by xissburg on 3/12/13.
//
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import "XBAnimationManager.h"

@interface XBPage : NSObject

@property (nonatomic, assign) BOOL opaque; // Whether the page texture is opaque
@property (nonatomic, readonly) GLuint textureWidth;
@property (nonatomic, readonly) GLuint textureHeight;
@property (nonatomic, readonly) GLuint frontTexture;
@property (nonatomic, readonly) GLuint backTexture;
@property (nonatomic, assign) CGPoint cylinderPosition;
@property (nonatomic, assign) CGFloat cylinderAngle;
@property (nonatomic, assign) CGFloat cylinderRadius;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGPoint center;

/**
 * Initializers
 * The horizontalResolution: and verticalResolution arguments determine how many rows and colums of quads (two triangles) the 3D
 * page mesh should have. By default, it has 1/10th of the view size, which is good enough for most situations. You should only
 * use a higher resolution if your cylinder radius goes under ~20.
 */
- (id)initWithContext:(EAGLContext *)context animationManager:(XBAnimationManager *)animationManager frame:(CGRect)frame;

/**
 * The following set of methods allows you to set the cylinder properties, namely, the (x,y) position of its axis,
 * the angle of its axis and its radius. The position is specified in UIKit's coordinate system: origin at the top
 * left corner, x increases towards the right and y increases towards the bottom. In the zoomed-out two-page
 * configuration though, the origin is at the center horizontally and at the top vertically, but the cylinder axis
 * cant pass the central, vertical axis (which holds the page in place). The angle is specified in radians and
 * increases in counter clockwise direction. The radius allows you to control the curvature of the curled section
 * of the page.
 */
- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration interpolator:(double (^)(double t))interpolator completion:(void (^)(void))completion;
- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration interpolator:(double (^)(double t))interpolator completion:(void (^)(void))completion;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration interpolator:(double (^)(double t))interpolator completion:(void (^)(void))completion;

- (void)drawImageOnFrontOfPage:(UIImage *)image;
- (void)drawViewOnFrontOfPage:(UIView *)view;

- (void)drawImageOnBackOfPage:(UIImage *)image;
- (void)drawViewOnBackOfPage:(UIView *)view;

- (BOOL)pointInside:(CGPoint)point;

@end
