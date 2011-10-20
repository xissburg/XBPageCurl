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


/**
 * A view that renders a curled version of an image or a UIView instance using OpenGL.
 */
@interface XBCurlView : UIView {
    EAGLContext *_context;
    CADisplayLink *_displayLink;
    
    //OpenGL buffers.
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    GLuint sampleFramebuffer;
    GLuint sampleColorRenderbuffer;
    GLuint sampleDepthRenderbuffer;
    
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
    GLuint texSizeHandle;
    GLuint cylinderPositionHandle, cylinderDirectionHandle, cylinderRadiusHandle;
    
    //Texture projected onto the two-triangle rectangle of the nextPage.
    GLuint nextPageTexture;
    
    //Very simple GPU program for the nextPage.
    GLuint nextPageProgram;
    
    //Vertex buffer for the two-triangle rectangle of the nextPage.
    //No need for an index buffer. It is drawn as a triangle-strip.
    GLuint nextPageVertexBuffer;
    
    //Handles for the nextPageProgram variables.
    GLuint nextPagePositionHandle, nextPageTexCoordHandle, nextPageMvpHandle, nextPageSamplerHandle, nextPageTexSizeHandle;
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
@property (nonatomic, assign) BOOL pageOpaque;
@property (nonatomic, readonly) NSUInteger horizontalResolution; //Number of colums of rectangles
@property (nonatomic, readonly) NSUInteger verticalResolution; //Number of rows..
@property (nonatomic, assign) CGPoint cylinderPosition;
@property (nonatomic, assign) CGFloat cylinderAngle;
@property (nonatomic, assign) CGFloat cylinderRadius;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame antialiasing:(BOOL)antialiasing;
- (id)initWithFrame:(CGRect)frame horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution antialiasing:(BOOL)antialiasing;

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

/**
 * Starts/stops the CADisplayLink that updates and redraws everything in this view.
 * This should be called manually whenever you are going to present this view and change its properties 
 * (for example, before adding it as subview and changing the cylinder properties). stopAnimating should
 * be called whenever you don't need to animate this anymore (for example, after removing it from superview).
 */
- (void)startAnimating;
- (void)stopAnimating;

- (void)drawImageOnFrontOfPage:(UIImage *)image;
- (void)drawViewOnFrontOfPage:(UIView *)view;

- (void)drawImageOnBackOfPage:(UIImage *)image;
- (void)drawViewOnBackOfPage:(UIView *)view;

- (void)drawImageOnNextPage:(UIImage *)image;
- (void)drawViewOnNextPage:(UIView *)view;

- (void)curlView:(UIView *)view cylinderPosition:(CGPoint)cylinderPosition cylinderAngle:(CGFloat)cylinderAngle cylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration;
- (void)uncurlAnimatedWithDuration:(NSTimeInterval)duration;

@end
