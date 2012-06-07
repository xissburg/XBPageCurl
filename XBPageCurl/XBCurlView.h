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


/**
 * A view that renders a curled version of an image or a UIView instance using OpenGL.
 */
@interface XBCurlView : UIView {
    EAGLContext *_context;
    CADisplayLink *_displayLink;
    
    //OpenGL buffers.
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLuint sampleFramebuffer;
    GLuint sampleColorRenderbuffer;
    
    //Texture size for all possible textures (front of page, back of page, nextPage).
    GLuint textureWidth, textureHeight;
    
    //Texture projected onto the front of the curling mesh.
    GLuint frontTexture;
    
    //Texture projected onto the back of the curling mesh for double-sided pages.
    GLuint backTexture;
    
    //GPU program for the curling mesh.
    GLuint program;
    
    //Vertex and index buffer for the curling mesh.
    GLuint vertexBuffer;
    GLuint indexBuffer;
    GLuint elementCount; //Number of entries in the index buffer
    
    //Handles for the curl shader variables.
    GLuint positionHandle, texCoordHandle, mvpHandle, samplerHandle;
    GLuint cylinderPositionHandle, cylinderDirectionHandle, cylinderRadiusHandle;
    
    //Texture projected onto the two-triangle rectangle of the nextPage.
    GLuint nextPageTexture;
    
    //Very simple GPU program for the nextPage.
    GLuint nextPageProgram;
    
    //Vertex buffer for the two-triangle rectangle of the nextPage.
    //No need for an index buffer. It is drawn as a triangle-strip.
    GLuint nextPageVertexBuffer;
    
    //Handles for the nextPageProgram variables.
    GLuint nextPagePositionHandle, nextPageTexCoordHandle, nextPageMvpHandle, nextPageSamplerHandle;
    GLuint nextPageCylinderPositionHandle, nextPageCylinderDirectionHandle, nextPageCylinderRadiusHandle;
    
    //Viewport/view/screen size.
    GLint viewportWidth, viewportHeight;
    
    //Model-View-Proj matrix.
    GLfloat mvp[16];
    
    //Position of any point in the cylinder axis projected on the xy plane.
    CGPoint _cylinderPosition;
    //Angle for the cylinder axis.
    CGFloat _cylinderAngle;
    CGFloat _cylinderRadius;
    
    //Multisampling anti-aliasing flag. It can only be set at init time.
    BOOL _antialiasing;
    
    //Resolution of the grid mesh
    NSUInteger _horizontalResolution, _verticalResolution;
    
    //Screen scale
    CGFloat _screenScale;
}

@property (nonatomic, readonly) BOOL antialiasing;
@property (nonatomic, assign) BOOL pageOpaque; // Wether the page texture is opaque
@property (nonatomic, readonly) NSUInteger horizontalResolution; //Number of colums of rectangles
@property (nonatomic, readonly) NSUInteger verticalResolution; //Number of rows..
@property (nonatomic, assign) CGPoint cylinderPosition;
@property (nonatomic, assign) CGFloat cylinderAngle;
@property (nonatomic, assign) CGFloat cylinderRadius;

/**
 * Initializers
 * The horizontalResolution: and verticalResolution arguments determine how many rows anc colums of quads (two triangles) the page
 * curling 3D mesh should have. By default, it uses 1/10th of the view size, which is good enough for most situations. You should
 * only use a higher resolution if you want to use a very low cylinder radius, below 20.
 */
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame antialiasing:(BOOL)antialiasing;
- (id)initWithFrame:(CGRect)frame horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution antialiasing:(BOOL)antialiasing;

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

/**
 * Starts/stops the CADisplayLink that updates and redraws everything in this view.
 * This should be called manually whenever you are going to present this view and change its properties 
 * (for example, before adding it as subview and changing the cylinder properties). stopAnimating should
 * be called whenever you don't need to animate this anymore (for example, after removing it from superview),
 * otherwise your XBCurlView instance won't be deallocated because, internally, the CADisplayLink retains its
 * target which is the XBCurlView instance itself.
 */
- (void)startAnimating;
- (void)stopAnimating;

- (void)drawImageOnFrontOfPage:(UIImage *)image;
- (void)drawViewOnFrontOfPage:(UIView *)view;

- (void)drawImageOnBackOfPage:(UIImage *)image;
- (void)drawViewOnBackOfPage:(UIView *)view;

/**
 * The nextPage is a page that is rendered behind the curled page. You can set the XBCurlView opaque property
 * to NO in order to see whatever view is behind the XBCurlView through the pixels not filled by the curled page.
 * You can also set it to YES and draw something in a texture to be rendered as the nextPage, using one of the
 * methods below. Depending on your configuration and needs, it may be more efficient to draw just a texture than
 * a full view. Also, they say a view backed by an CAEAGLLayer should be opaque for a better performance.
 */
- (void)drawImageOnNextPage:(UIImage *)image;
- (void)drawViewOnNextPage:(UIView *)view;

/**
 * The following methods allow you to curl a view without much code. Just choose the cylinder properties and go. Later you can uncurl it.
 * It adds and removes itself to/from the target view automatically.
 */
- (void)curlView:(UIView *)view cylinderPosition:(CGPoint)cylinderPosition cylinderAngle:(CGFloat)cylinderAngle cylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration;
- (void)uncurlAnimatedWithDuration:(NSTimeInterval)duration;

@end
