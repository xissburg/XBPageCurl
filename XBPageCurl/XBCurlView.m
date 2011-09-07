//
//  XBCurlView.m
//  XBPageCurl
//
//  Created by xiss burg on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XBCurlView.h"
#import "XBAnimation.h"
#import "XBAnimationManager.h"
#import <QuartzCore/QuartzCore.h>


typedef struct _Vertex
{
    GLfloat x, y, z;
    GLfloat u, v;
    GLubyte color[4];
} Vertex;

void OrthoM4x4(GLfloat *out, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far);
void MultiplyM4x4(const GLfloat *A, const GLfloat *B, GLfloat *out);
CGContextRef CreateARGBBitmapContext (size_t pixelsWide, size_t pixelsHigh);

/**
 * A view that renders a curled version of an image or a UIView instance using OpenGL.
 */
@interface XBCurlView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) XBAnimationManager *animationManager;

- (void)createFramebuffer;
- (void)destroyFramebuffer;
- (void)createVertexBufferWithXRes:(GLuint)xRes yRes:(GLuint)yRes;
- (void)destroyVertexBuffer;
- (BOOL)setupShaders;
- (void)destroyShaders;
- (void)setupMVP;
- (void)createTextureFromView:(UIView *)view;
- (void)startAnimating;
- (void)stopAnimating;
- (void)draw:(CADisplayLink *)sender;

@end

#define kCylinderPositionAnimationName @"cylinderPosition"
#define kCylinderDirectionAnimationName @"cylinderDirection"
#define kCylinderRadiusAnimationName @"cylinderRadius"


@implementation XBCurlView

@synthesize context=_context, displayLink=_displayLink, antialiasing=_antialiasing;
@synthesize cylinderPosition=_cylinderPosition, cylinderDirection=_cylinderDirection, cylinderRadius=_cylinderRadius;
@synthesize horizontalResolution=_horizontalResolution, verticalResolution=_verticalResolution;
@synthesize backingView=_backingView;
@synthesize animationManager;

- (BOOL)initialize
{
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (_context == nil || [EAGLContext setCurrentContext:self.context] == NO) {
        return NO;
    }
    
    if (![self setupShaders]) {
        return NO;
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
    
    self.animationManager = [XBAnimationManager animationManager];

    self.cylinderPosition = CGPointMake(0, 0);
    self.cylinderDirection = CGPointMake(0, 1);
    self.cylinderRadius = 32;
    
    framebuffer = colorRenderbuffer = depthRenderbuffer = 0;
    sampleFramebuffer = sampleColorRenderbuffer = sampleDepthRenderbuffer = 0;
    vertexBuffer = indexBuffer = elementCount = 0;
    texture = 0;
    
    return YES;
}

- (id)initWithView:(UIView *)view
{
    return [self initWithView:view antialiasing:NO];
}

- (id)initWithView:(UIView *)view antialiasing:(BOOL)antialiasing
{
    return [self initWithView:view antialiasing:antialiasing horizontalResolution:32 verticalResolution:48];
}

- (id)initWithView:(UIView *)view antialiasing:(BOOL)antialiasing horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution
{
    CGRect frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        _antialiasing = antialiasing;
        _horizontalResolution = horizontalResolution;
        _verticalResolution = verticalResolution;
        
        if (![self initialize]) {
            [self release];
            return nil;
        }
        
        _backingView = [view retain];
        
        [self createTextureFromView:_backingView];
    }
    return self;
}

- (void)dealloc
{
    self.context = nil;
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.animationManager = nil;
    [self destroyVertexBuffer];
    [self destroyShaders];
    [self destroyFramebuffer];
    [_backingView release];
    
    [super dealloc];
}


#pragma mark - Overrides

+ (Class)layerClass 
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:self.context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    
    [self setupMVP];
    
    /* Vertex buffer is initialized here because it needs to know the viewport size, 
     * which is only available after creating the framebuffer for the first time. */
    if (vertexBuffer == 0) {
        [self createVertexBufferWithXRes:self.horizontalResolution yRes:self.verticalResolution];
    }
    
    if (self.displayLink == nil) {
        [self startAnimating];
    }
}


#pragma mark - Properties

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration
{
    CGPoint p0 = self.cylinderPosition;
    
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderPositionAnimationName duration:duration update:^(double t) {
        _cylinderPosition = CGPointMake((1 - t)*p0.x + t*cylinderPosition.x, (1 - t)*p0.y + t*cylinderPosition.y);
    }];
    
    [self.animationManager runAnimation:animation];
}

- (void)setCylinderDirection:(CGPoint)cylinderDirection animatedWithDuration:(NSTimeInterval)duration
{
    CGPoint d0 = self.cylinderDirection;
    
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderDirectionAnimationName duration:duration update:^(double t) {
        _cylinderDirection = CGPointMake((1 - t)*d0.x + t*cylinderDirection.x, (1 - t)*d0.y + t*cylinderDirection.y);
    }];
    
    [self.animationManager runAnimation:animation];
}

- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration
{
    CGFloat r = self.cylinderRadius;
    
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderRadiusAnimationName duration:duration update:^(double t) {
        _cylinderRadius = (1 - t)*r + t*cylinderRadius;
    }];
    
    [self.animationManager runAnimation:animation];
}


#pragma mark - Methods

- (void)createFramebuffer
{
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &viewportWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &viewportHeight);
    
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, viewportWidth, viewportHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to create framebuffer: %x", status);
    }
    
    //Create multisampling buffers
    if (self.antialiasing) {
        glGenFramebuffers(1, &sampleFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, sampleFramebuffer);
        
        glGenRenderbuffers(1, &sampleColorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, sampleColorRenderbuffer);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, viewportWidth, viewportHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, sampleColorRenderbuffer);
        
        glGenRenderbuffers(1, &sampleDepthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, sampleDepthRenderbuffer);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, viewportWidth, viewportHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, sampleDepthRenderbuffer);
        
        status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Failed to create multisamping framebuffer: %x", status);
        }
    }    
}

- (void)destroyFramebuffer
{
    glDeleteFramebuffers(1, &framebuffer);
    framebuffer = 0;
    
    glDeleteRenderbuffers(1, &colorRenderbuffer);
    colorRenderbuffer = 0;
    
    glDeleteRenderbuffers(1, &depthRenderbuffer);
    depthRenderbuffer = 0;
    
    glDeleteFramebuffers(1, &sampleFramebuffer);
    sampleFramebuffer = 0;
    
    glDeleteRenderbuffers(1, &sampleColorRenderbuffer);
    sampleColorRenderbuffer = 0;
    
    glDeleteRenderbuffers(1, &sampleDepthRenderbuffer);
    sampleDepthRenderbuffer = 0;
}

- (void)createVertexBufferWithXRes:(GLuint)xRes yRes:(GLuint)yRes
{
    GLsizeiptr verticesSize = (xRes+1)*(yRes+1)*sizeof(Vertex);
    Vertex *vertices = malloc(verticesSize);
    
    GLubyte (^RandomByte)(void) = ^(void) {
        return (GLubyte)(((double)arc4random()/((1LL<<32)-1))*255);
    };
    
    for (int y=0; y<yRes+1; ++y) {
        GLfloat vy = ((GLfloat)y/yRes)*viewportHeight;
        GLfloat tv = vy;///viewportHeight;
        for (int x=0; x<xRes+1; ++x) {
            Vertex *v = &vertices[y*(xRes+1) + x];
            v->x = ((GLfloat)x/xRes)*viewportWidth;
            v->y = vy;
            v->z = 0;
            v->u = v->x;///viewportWidth;
            v->v = tv;
            v->color[0] = RandomByte();
            v->color[1] = RandomByte();
            v->color[2] = RandomByte();
            v->color[3] = 255;
        }
    }
    
    elementCount = xRes*yRes*2*3;
    GLsizeiptr indicesSize = elementCount*sizeof(GLushort);//Two triangles per square, 3 indices per triangle
    GLushort *indices = malloc(indicesSize);
    
    for (int y=0; y<yRes; ++y) {
        for (int x=0; x<xRes; ++x) {
            int i = y*(xRes+1) + x;
            int idx = y*xRes + x;
            assert(i < elementCount*3-1);
            indices[idx*6+0] = i;
            indices[idx*6+1] = i + 1;
            indices[idx*6+2] = i + xRes + 1;
            indices[idx*6+3] = i + 1;
            indices[idx*6+4] = i + xRes + 2;
            indices[idx*6+5] = i + xRes + 1;
        }
    }
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, verticesSize, (GLvoid *)vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesSize, (GLvoid *)indices, GL_STATIC_DRAW);
    
    free(vertices);
    free(indices);
}

- (void)destroyVertexBuffer
{
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteBuffers(1, &indexBuffer);
    vertexBuffer = indexBuffer = 0;
}

- (void)setupMVP
{
    OrthoM4x4(mvp, 0.f, viewportWidth, 0.f, viewportHeight, -1000.f, 1000.f);
}

- (GLuint)loadShader:(NSString *)filename type:(GLenum)type 
{
    GLuint shader = glCreateShader(type);
    
    if (shader == 0) {
        return 0;
    }
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    const GLchar *shaderSource = [shaderString cStringUsingEncoding:NSUTF8StringEncoding];
    
    glShaderSource(shader, 1, &shaderSource, NULL);
    glCompileShader(shader);
    
    GLint success = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    
    if (success == 0) {
        char errorMsg[2048];
        glGetShaderInfoLog(shader, sizeof(errorMsg), NULL, errorMsg);
        NSString *errorString = [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding];
        NSLog(@"Failed to compile %@: %@", filename, errorString);
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

- (BOOL)setupShaders
{
    GLuint vertexShader = [self loadShader:@"VertexProgram.glsl" type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShader:@"FragmentProgram.glsl" type:GL_FRAGMENT_SHADER];
    program = glCreateProgram();
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    GLint linked = 0;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (linked == 0) {
        glDeleteProgram(program);
        return NO;
    }
    
    positionHandle          = glGetAttribLocation(program, "a_position");
    texCoordHandle          = glGetAttribLocation(program, "a_texCoord");
    colorHandle             = glGetAttribLocation(program, "a_color");
    mvpHandle               = glGetUniformLocation(program, "u_mvpMatrix");
    samplerHandle           = glGetUniformLocation(program, "s_tex");
    texSizeHandle           = glGetUniformLocation(program, "u_texSize");
    cylinderPositionHandle  = glGetUniformLocation(program, "u_cylinderPosition");
    cylinderDirectionHandle = glGetUniformLocation(program, "u_cylinderDirection");
    cylinderRadiusHandle    = glGetUniformLocation(program, "u_cylinderRadius");
    
    return YES;
}

- (void)destroyShaders
{
    glDeleteProgram(program);
    program = 0;
}

- (void)createTextureFromView:(UIView *)view
{
    //Compute the actual view size in the current screen scale
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize actualViewSize = actualViewSize = CGSizeMake(view.bounds.size.width*scale, view.bounds.size.height*scale);
    
    //Compute the closest, greater power of two
    CGFloat textureWidth = 1<<((int)floorf(log2f(actualViewSize.width - 1)) + 1);
    CGFloat textureHeight = 1<<((int)floorf(log2f(actualViewSize.height - 1)) + 1);
    
    if (textureWidth < 64) {
        textureWidth = 64;
    }
    
    if (textureHeight < 64) {
        textureHeight = 64;
    }
    
    //Set shader texture scale
    glUseProgram(program);
    glUniform2f(texSizeHandle, textureWidth, textureHeight);
    glUseProgram(0);
    
    NSLog(@"Texture size %dx%d", (int)textureWidth, (int)textureHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerChannel = 8;
    NSUInteger bytesPerRow = bytesPerPixel * textureWidth;
    GLubyte *textureData = malloc(textureWidth * textureHeight * bytesPerPixel * sizeof(GLubyte));
    int pattern = 0xff7f7f7f;
    memset_pattern4(textureData, &pattern, textureWidth * textureHeight * bytesPerPixel);
    CGContextRef bitmapContext = CGBitmapContextCreate(textureData, textureWidth, textureHeight, bitsPerChannel, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(bitmapContext, 0, textureHeight-view.layer.bounds.size.height);
    [view.layer renderInContext:bitmapContext];
    
    CGContextRelease(bitmapContext);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    glBindTexture(GL_TEXTURE_2D, 0);
  
    free(textureData);
}

- (void)startAnimating
{
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(draw:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopAnimating
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)draw:(CADisplayLink *)sender
{
    //Update all animations
    [self.animationManager update:sender.duration];
    
    //Render
    [EAGLContext setCurrentContext:self.context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _antialiasing? sampleFramebuffer: framebuffer);
    glViewport(0, 0, viewportWidth, viewportHeight);
    
    glClearColor(0.4, 0.4, 0.4, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(program);
    
    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    glUniform2f(cylinderPositionHandle, self.cylinderPosition.x, self.cylinderPosition.y);
    glUniform2f(cylinderDirectionHandle, self.cylinderDirection.x, self.cylinderDirection.y);
    glUniform1f(cylinderRadiusHandle, self.cylinderRadius);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glVertexAttribPointer(positionHandle, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, x));
    glEnableVertexAttribArray(positionHandle);
    glVertexAttribPointer(texCoordHandle, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, u));
    glEnableVertexAttribArray(texCoordHandle);
    glVertexAttribPointer(colorHandle, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(Vertex), (void *)offsetof(Vertex, color));
    glEnableVertexAttribArray(colorHandle);
    glUniformMatrix4fv(mvpHandle, 1, GL_FALSE, mvp);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(samplerHandle, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glDrawElements(GL_TRIANGLES, elementCount, GL_UNSIGNED_SHORT, (void *)0);
    
    if (_antialiasing) {
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, sampleFramebuffer);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, framebuffer);
        glResolveMultisampleFramebufferAPPLE();
        
        GLenum attachments[] = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"%d", error);
    }
}

@end


#pragma mark - Functions

void MultiplyM4x4(const GLfloat *A, const GLfloat *B, GLfloat *out)
{
    for (int i=0; i<4; ++i) {
        for (int j=0; j<4; ++j) {
            GLfloat f = 0.f;
            for (int k=0; k<4; ++k) {
                f += A[i*4+k] * B[k*4+j];
            }
            out[i*4+j] = f;
        }
    }
}

void OrthoM4x4(GLfloat *out, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far)
{
    out[0] = 2.f/(right-left); out[4] = 0.f; out[8] = 0.f; out[12] = -(right+left)/(right-left);
    out[1] = 0.f; out[5] = 2.f/(top-bottom); out[9] = 0.f; out[13] = -(top+bottom)/(top-bottom);
    out[2] = 0.f; out[6] = 0.f; out[10] = -2.f/(far-near); out[14] = -(far+near)/(far-near);
    out[3] = 0.f; out[7] = 0.f; out[11] = 0.f; out[15] = 1.f;
}

