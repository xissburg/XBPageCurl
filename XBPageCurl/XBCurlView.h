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
    
    //GPU program.
    GLuint program;
    
    //Texture projected onto the curling mesh.
    GLuint texture;
    GLuint textureWidth, textureHeight;
    
    //Mesh stuff.
    GLuint vertexBuffer;
    GLuint indexBuffer;
    GLuint elementCount; //Number of entries in the index buffer
    
    //Viewport/view/screen size.
    GLint viewportWidth, viewportHeight;
    
    //Model-View-Proj matrix.
    GLfloat mvp[16];
    
    //Handles for the shader variables.
    int positionHandle, texCoordHandle, mvpHandle, samplerHandle;
    int texSizeHandle;
    int cylinderPositionHandle, cylinderDirectionHandle, cylinderRadiusHandle;
    
    //Position of any point in the cylinder axis projected on the xy plane.
    CGPoint _cylinderPosition;
    //Direction vector (normalized) for the cylinder axis.
    CGPoint _cylinderDirection;
    CGFloat _cylinderRadius;
    
    //Multisampling anti-aliasing flag. It can only be set at init time.
    BOOL _antialiasing;
    
    //Resolution of the grid mesh
    NSUInteger _horizontalResolution, _verticalResolution;
}

@property (nonatomic, readonly) BOOL antialiasing;
@property (nonatomic, readonly) NSUInteger horizontalResolution; //Number of colums of rectangles
@property (nonatomic, readonly) NSUInteger verticalResolution; //Number of rows..
@property (nonatomic, assign) CGPoint cylinderPosition;
@property (nonatomic, assign) CGPoint cylinderDirection;
@property (nonatomic, assign) CGFloat cylinderRadius;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame antialiasing:(BOOL)antialiasing;
- (id)initWithFrame:(CGRect)frame horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution antialiasing:(BOOL)antialiasing;

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)setCylinderDirection:(CGPoint)cylinderDirection animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderDirection:(CGPoint)cylinderDirection animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration;
- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

/**
 * Starts/stops the CADisplayLink that updates and redraws everything in this view.
 * This should be called manually whenever you are going to present this view and change its properties 
 * (for example, before adding it as subview). stopAnimating should be called whenever you don't need 
 * to animate this anymor (for example, after removing it from superview).
 */
- (void)startAnimating;
- (void)stopAnimating;

- (void)drawImageOnTexture:(UIImage *)image;
- (void)drawViewOnTexture:(UIView *)view;

@end
