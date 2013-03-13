//
//  XBCurlView.h
//  XBPageCurl
//
//  Created by xiss burg on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "XBAnimation.h"
#import "XBAnimationManager.h"
#import "XBPage.h"

/**
 * A view that renders a curled version of an image or a UIView instance using OpenGL.
 */
@interface XBCurlView : UIView 

@property (nonatomic, readonly) BOOL antialiasing;
@property (nonatomic, readonly) NSUInteger horizontalResolution; //Number of colums of rectangles
@property (nonatomic, readonly) NSUInteger verticalResolution; //Number of rows..

/**
 * Initializers
 * The horizontalResolution: and verticalResolution arguments determine how many rows and colums of quads (two triangles) the 3D
 * page mesh should have. By default, it has 1/10th of the view size, which is good enough for most situations. You should only 
 * use a higher resolution if your cylinder radius goes under ~20.
 */
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame antialiasing:(BOOL)antialiasing;
- (id)initWithFrame:(CGRect)frame horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution antialiasing:(BOOL)antialiasing;

/**
 * Starts/stops the CADisplayLink that updates and redraws everything in this view.
 * This should be called manually whenever you are going to present this view and change its properties 
 * (for example, before adding it as subview and changing the cylinder properties). stopAnimating should
 * be called whenever you don't need to animate this anymore (for example, after removing it from superview),
 * otherwise your XBCurlView instance won't be deallocated because, internally, the CADisplayLink retains its
 * target which is the XBCurlView instance itself. So, if you call startAnimating, you must call stopAnimating
 * later.
 */
- (void)startAnimating;
- (void)stopAnimating;

/**
 *
 */
- (XBPage *)pageWithFrame:(CGRect)frame;
- (void)removePage:(XBPage *)page;
- (XBPage *)pageAtPoint:(CGPoint)point;

/**
 * The following methods allow you to curl a view without much code. Just choose the cylinder properties and go. You can uncurl 
 * it afterwards. It adds and removes itself to/from the target view automatically.
 */
- (XBPage *)curlView:(UIView *)view cylinderPosition:(CGPoint)cylinderPosition cylinderAngle:(CGFloat)cylinderAngle cylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration;
- (void)uncurlPage:(XBPage *)page animatedWithDuration:(NSTimeInterval)duration;
- (void)uncurlPage:(XBPage *)page animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

/**
 * Returns an UIImage instance with the current contents of the main framebuffer.
 */
- (UIImage *)imageFromFramebuffer;

/**
 * Returns an UIImage instance with the current contents of the main framebuffer and a background view that can
 * be seen through the transparent regions of the page.
 */
- (UIImage *)imageFromFramebufferWithBackgroundView:(UIView *)backgroundView;

@end
