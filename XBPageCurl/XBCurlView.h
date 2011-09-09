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


@interface XBCurlView : UIView {
    EAGLContext *_context;
    CADisplayLink *_displayLink;
    UIView *_backingView;
    
    //OpenGL buffers.
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    GLuint sampleFramebuffer;
    GLuint sampleColorRenderbuffer;
    GLuint sampleDepthRenderbuffer;
    
    //GPU program.
    GLuint program;
    
    //Texture projected onto the curling mesh.
    GLuint texture;
    GLuint textureWidth, textureHeight;
    
    //Mesh stuff.
    GLuint vertexBuffer;
    GLuint indexBuffer;
    GLuint elementCount;
    
    //Viewport/view/screen size.
    GLint viewportWidth, viewportHeight;
    
    //Model-View-Proj matrix.
    GLfloat mvp[16];
    
    //Handles for the shader variables.
    int positionHandle, texCoordHandle, colorHandle, mvpHandle, samplerHandle;
    int texSizeHandle;
    int cylinderPositionHandle, cylinderDirectionHandle, cylinderRadiusHandle;
    
    //Position of any point in the cylinder axis projected on the xy plane.
    CGPoint _cylinderPosition;
    //Direction vector (normalized) for the cylinder axis.
    CGPoint _cylinderDirection;
    CGFloat _cylinderRadius;
    
    //Multisampling anti-aliasing flag. It can only be set at creation time.
    BOOL _antialiasing;
    
    //Resolution of the grid mesh
    NSUInteger _horizontalResolution, _verticalResolution;
}

@property (nonatomic, readonly) UIView *backingView;
@property (nonatomic, readonly) BOOL antialiasing;
@property (nonatomic, readonly) NSUInteger horizontalResolution; //Number of colums of rectangles
@property (nonatomic, readonly) NSUInteger verticalResolution; //Number of rows..
@property (nonatomic, assign) CGPoint cylinderPosition;
@property (nonatomic, assign) CGPoint cylinderDirection;
@property (nonatomic, assign) CGFloat cylinderRadius;

/*
- (id)initWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image antialiasing:(BOOL)antialiasing;
- (id)initWithImage:(UIImage *)image antialiasing:(BOOL)antialiasing horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution;
 */
- (id)initWithView:(UIView *)view;
- (id)initWithView:(UIView *)view antialiasing:(BOOL)antialiasing;
- (id)initWithView:(UIView *)view antialiasing:(BOOL)antialiasing horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution;

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderDirection:(CGPoint)cylinderDirection animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

- (void)startAnimating;
- (void)stopAnimating;

@end
