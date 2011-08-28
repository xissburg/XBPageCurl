//
//  XBPageCurlView.h
//  XBPageCurl
//
//  Created by xiss burg on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface XBPageCurlView : UIView {
    EAGLContext *_context;
    CADisplayLink *_displayLink;
    
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    GLuint sampleFramebuffer;
    GLuint sampleColorRenderbuffer;
    GLuint sampleDepthRenderbuffer;
    GLuint program;
    GLuint texture;
    
    GLuint vertexBuffer;
    GLuint indexBuffer;
    GLuint elementCount;
    
    GLint viewportWidth, viewportHeight;
    GLfloat mvp[16];
    
    int positionHandle, texCoordHandle, colorHandle, mvpHandle, samplerHandle;
    int texSizeHandle;
    int cylinderPositionHandle, cylinderDirectionHandle, cylinderRadiusHandle;
    
    CGPoint cylinderPosition;
    CGPoint cylinderDirection;
    CGFloat cylinderRadius;
    CGPoint startPickingPosition;
}

- (id)initWithView:(UIView *)view;

@end
