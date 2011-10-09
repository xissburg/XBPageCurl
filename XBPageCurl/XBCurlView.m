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
} Vertex;

void OrthoM4x4(GLfloat *out, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far);
void MultiplyM4x4(const GLfloat *A, const GLfloat *B, GLfloat *out);

@interface XBCurlView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) XBAnimationManager *animationManager;
@property (nonatomic, retain) UIView *curlingView; //UIView being curled only used in curlView: and uncurlAnimatedWithDuration: methods
@property (nonatomic, readonly) CGFloat screenScale;

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;
- (void)createVertexBufferWithXRes:(GLuint)xRes yRes:(GLuint)yRes;
- (void)destroyVertexBuffer;
- (void)createNextPageVertexBuffer;
- (void)destroyNextPageVertexBuffer;
- (void)destroyNextPageTexture;
- (BOOL)setupShaders;
- (void)destroyShaders;
- (void)setupMVP;
- (CGSize)minimumFullSizedTextureSize;
- (GLuint)generateTexture;
- (void)drawImage:(UIImage *)image onTexture:(GLuint)texture;
- (void)drawView:(UIView *)view onTexture:(GLuint)texture;
- (void)draw:(CADisplayLink *)sender;

@end

#define kCylinderPositionAnimationName @"cylinderPosition"
#define kCylinderDirectionAnimationName @"cylinderDirection"
#define kCylinderRadiusAnimationName @"cylinderRadius"


@implementation XBCurlView

@synthesize context=_context, displayLink=_displayLink, antialiasing=_antialiasing;
@synthesize horizontalResolution=_horizontalResolution, verticalResolution=_verticalResolution;
@synthesize animationManager, curlingView, pageOpaque;
@synthesize cylinderAngle=_cylinderAngle;
@synthesize screenScale=_screenScale;

- (BOOL)initialize
{
    //Setup scale before everything
    _screenScale = [[UIScreen mainScreen] scale];
    [self setContentScaleFactor:self.screenScale];
    
    self.pageOpaque = YES;
    self.opaque = YES;
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
    
    self.animationManager = [XBAnimationManager animationManager];

    self.cylinderPosition = CGPointMake(0, 0);
    self.cylinderAngle = M_PI_2;
    self.cylinderRadius = 32;
    
    framebuffer = colorRenderbuffer = depthRenderbuffer = 0;
    sampleFramebuffer = sampleColorRenderbuffer = sampleDepthRenderbuffer = 0;
    vertexBuffer = indexBuffer = elementCount = 0;
    frontTexture = 0;
    
    if (![self createFramebuffer]) {
        return NO;
    }
    
    [self setupMVP];
    
    CGSize textureSize = [self minimumFullSizedTextureSize];
    textureWidth = (GLuint)textureSize.width;
    textureHeight = (GLuint)textureSize.height;
    frontTexture = [self generateTexture];
    
    //Set shader texture scale
    glUseProgram(program);
    glUniform2f(texSizeHandle, textureWidth, textureHeight);
    
    glUseProgram(nextPageProgram);
    glUniform2f(nextPageTexSizeHandle, textureWidth, textureHeight);
    glUseProgram(0);
    
    return YES;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame antialiasing:NO];
}

- (id)initWithFrame:(CGRect)frame antialiasing:(BOOL)antialiasing;
{
    return [self initWithFrame:frame horizontalResolution:(NSUInteger)(frame.size.width/10) verticalResolution:(NSUInteger)(frame.size.height/10) antialiasing:antialiasing];
}

- (id)initWithFrame:(CGRect)frame horizontalResolution:(NSUInteger)horizontalResolution verticalResolution:(NSUInteger)verticalResolution antialiasing:(BOOL)antialiasing
{
    self = [super initWithFrame:frame];
    if (self) {
        _antialiasing = antialiasing;
        _horizontalResolution = horizontalResolution;
        _verticalResolution = verticalResolution;
        
        if (![self initialize]) {
            [self release];
            return nil;
        }
        
        [self createVertexBufferWithXRes:self.horizontalResolution yRes:self.verticalResolution];
        [self createNextPageVertexBuffer];
    }
    return self;
}

- (void)dealloc
{
    self.context = nil;
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.animationManager = nil;
    self.curlingView = nil;
    [self destroyVertexBuffer];
    [self destroyNextPageVertexBuffer];
    [self destroyShaders];
    [self destroyFramebuffer];

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
}


#pragma mark - Properties

//CylinderPosition
- (CGPoint)cylinderPosition
{
    return CGPointMake(_cylinderPosition.x/self.screenScale, _cylinderPosition.y/self.screenScale);
}

- (void)setCylinderPosition:(CGPoint)cylinderPosition
{
    _cylinderPosition = CGPointMake(cylinderPosition.x*self.screenScale, cylinderPosition.y*self.screenScale);
}

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration
{
    [self setCylinderPosition:cylinderPosition animatedWithDuration:duration completion:^(void) {}];
}

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    CGPoint p0 = self.cylinderPosition;
    
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderPositionAnimationName duration:duration update:^(double t) {
        self.cylinderPosition = CGPointMake((1 - t)*p0.x + t*cylinderPosition.x, (1 - t)*p0.y + t*cylinderPosition.y);
    } completion:completion];
    
    [self.animationManager runAnimation:animation];
}

//CylinderAngle
- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration
{
    [self setCylinderAngle:cylinderAngle animatedWithDuration:duration completion:^(void) {}];
}

- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    double a0 = _cylinderAngle;
    double a1 = cylinderAngle;
    
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderDirectionAnimationName duration:duration update:^(double t) {
        _cylinderAngle = (1 - t)*a0 + t*a1;
    } completion:completion];
    
    [self.animationManager runAnimation:animation];
}

//CylinderRadius
- (CGFloat)cylinderRadius
{
    return _cylinderRadius/self.screenScale;
}

- (void)setCylinderRadius:(CGFloat)cylinderRadius
{
    _cylinderRadius = cylinderRadius*self.screenScale;
}

- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration
{
    [self setCylinderRadius:cylinderRadius animatedWithDuration:duration completion:^(void) {}];
}

- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    CGFloat r = self.cylinderRadius;
    
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderRadiusAnimationName duration:duration update:^(double t) {
        self.cylinderRadius = (1 - t)*r + t*cylinderRadius;
    } completion:completion];
    
    [self.animationManager runAnimation:animation];
}


#pragma mark - Framebuffer

- (BOOL)createFramebuffer
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
        return NO;
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
            return NO;
        }
    }    
    
    return YES;
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


#pragma mark - Vertexbuffers

- (void)createVertexBufferWithXRes:(GLuint)xRes yRes:(GLuint)yRes
{
    [self destroyVertexBuffer];
    
    GLsizeiptr verticesSize = (xRes+1)*(yRes+1)*sizeof(Vertex);
    Vertex *vertices = malloc(verticesSize);
    
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

- (void)createNextPageVertexBuffer
{
    [self destroyNextPageVertexBuffer];
    
    GLsizeiptr verticesSize = 4*sizeof(Vertex);
    Vertex *vertices = malloc(verticesSize);
    
    vertices[0].x = 0;
    vertices[0].y = 0;
    vertices[0].z = -1;
    vertices[0].u = 0;
    vertices[0].v = 0;
    
    vertices[1].x = viewportWidth;
    vertices[1].y = 0;
    vertices[1].z = -1;
    vertices[1].u = viewportWidth;
    vertices[1].v = 0;
    
    vertices[2].x = 0;
    vertices[2].y = viewportHeight;
    vertices[2].z = -1;
    vertices[2].u = 0;
    vertices[2].v = viewportHeight;
    
    vertices[3].x = viewportWidth;
    vertices[3].y = viewportHeight;
    vertices[3].z = -1;
    vertices[3].u = viewportWidth;
    vertices[3].v = viewportHeight;
    
    glGenBuffers(1, &nextPageVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, nextPageVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, verticesSize, (GLvoid *)vertices, GL_STATIC_DRAW);
    
    free(vertices);
}

- (void)destroyNextPageVertexBuffer
{
    glDeleteBuffers(1, &nextPageVertexBuffer);
}

- (void)setupMVP
{
    OrthoM4x4(mvp, 0.f, viewportWidth, 0.f, viewportHeight, -1000.f, 1000.f);
}


#pragma mark - Shaders

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

- (BOOL)setupCurlShader
{
    GLuint vertexShader = [self loadShader:@"VertexShader.glsl" type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShader:@"FragmentShader.glsl" type:GL_FRAGMENT_SHADER];
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
    mvpHandle               = glGetUniformLocation(program, "u_mvpMatrix");
    samplerHandle           = glGetUniformLocation(program, "s_tex");
    texSizeHandle           = glGetUniformLocation(program, "u_texSize");
    cylinderPositionHandle  = glGetUniformLocation(program, "u_cylinderPosition");
    cylinderDirectionHandle = glGetUniformLocation(program, "u_cylinderDirection");
    cylinderRadiusHandle    = glGetUniformLocation(program, "u_cylinderRadius");
    
    return YES;
}

- (void)destroyCurlShader
{
    glDeleteProgram(program);
    program = 0;
}

- (BOOL)setupNextPageShader
{
    GLuint vertexShader = [self loadShader:@"NextPageVertexShader.glsl" type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self loadShader:@"NextPageFragmentShader.glsl" type:GL_FRAGMENT_SHADER];
    nextPageProgram = glCreateProgram();
    
    glAttachShader(nextPageProgram, vertexShader);
    glAttachShader(nextPageProgram, fragmentShader);
    glLinkProgram(nextPageProgram);
    
    GLint linked = 0;
    glGetProgramiv(nextPageProgram, GL_LINK_STATUS, &linked);
    if (linked == 0) {
        glDeleteProgram(nextPageProgram);
        return NO;
    }
    
    nextPagePositionHandle          = glGetAttribLocation(nextPageProgram, "a_position");
    nextPageTexCoordHandle          = glGetAttribLocation(nextPageProgram, "a_texCoord");
    nextPageMvpHandle               = glGetUniformLocation(nextPageProgram, "u_mvpMatrix");
    nextPageSamplerHandle           = glGetUniformLocation(nextPageProgram, "s_tex");
    nextPageTexSizeHandle           = glGetUniformLocation(nextPageProgram, "u_texSize");
    nextPageCylinderPositionHandle  = glGetUniformLocation(nextPageProgram, "u_cylinderPosition");
    nextPageCylinderDirectionHandle = glGetUniformLocation(nextPageProgram, "u_cylinderDirection");
    nextPageCylinderRadiusHandle    = glGetUniformLocation(nextPageProgram, "u_cylinderRadius");
    
    return YES;
}

- (void)destroyNextPageShader
{
    glDeleteProgram(nextPageProgram);
    nextPageProgram = 0;
}

- (BOOL)setupShaders
{
    if (![self setupCurlShader]) {
        return NO;
    }
    
    if (![self setupNextPageShader]) {
        return NO;
    }
    
    return YES;
}

- (void)destroyShaders
{
    [self destroyCurlShader];
    [self destroyNextPageShader];
}


#pragma mark - Textures

- (CGSize)minimumFullSizedTextureSize
{
    //Compute the actual view size in the current screen scale
    CGSize actualViewSize = CGSizeMake(self.frame.size.width*self.screenScale, self.frame.size.height*self.screenScale);
    
    //Compute the closest, greater power of two
    CGSize size = CGSizeZero;
    size.width = 1<<((int)floorf(log2f(actualViewSize.width - 1)) + 1);
    size.height = 1<<((int)floorf(log2f(actualViewSize.height - 1)) + 1);
    
    if (size.width < 64) {
        size.width = 64;
    }
    
    if (size.height < 64) {
        size.height = 64;
    }
    
    return size;
}

- (GLuint)generateTexture
{
    GLuint tex;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return tex;
}

- (void)drawImage:(UIImage *)image onTexture:(GLuint)texture
{
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGSize imageSize = CGSizeMake(textureWidth, textureHeight);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect r = CGRectMake(0, 0, width, height);
    CGContextClearRect(context, r);
    CGContextTranslateCTM(context, 0, height/self.screenScale);
    CGContextScaleCTM(context, 1, -1/self.screenScale);
    
    CGContextDrawImage(context, r, image.CGImage);
    
    GLubyte *textureData = (GLubyte *)CGBitmapContextGetData(context);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    UIGraphicsEndImageContext();
}

- (void)drawView:(UIView *)view onTexture:(GLuint)texture
{
    CGSize imageSize = CGSizeMake(textureWidth, textureHeight);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect r = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    CGContextClearRect(context, r);
    CGContextTranslateCTM(context, 0, view.layer.bounds.size.height/self.screenScale);
    CGContextScaleCTM(context, 1, -1/self.screenScale);
    
    [view.layer renderInContext:context];
    
    GLubyte *textureData = (GLubyte *)CGBitmapContextGetData(context);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, textureData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    UIGraphicsEndImageContext();
}

- (void)drawImageOnFrontOfPage:(UIImage *)image
{
    [self drawImage:image onTexture:frontTexture];
    
    //Force a redraw to avoid glitches
    [self draw:self.displayLink];
}

- (void)drawViewOnFrontOfPage:(UIView *)view
{
    [self drawView:view onTexture:frontTexture];
    
    //Force a redraw to avoid glitches
    [self draw:self.displayLink];
}

- (void)drawImageOnNextPage:(UIImage *)image
{
    if (image == nil) {
        [self destroyNextPageTexture];
        return;
    }
    
    if (nextPageTexture == 0) {
        nextPageTexture = [self generateTexture];
    }
    
    [self drawImage:image onTexture:nextPageTexture];
}

- (void)drawViewOnNextPage:(UIView *)view
{
    if (view == nil) {
        [self destroyNextPageTexture];
        return;
    }
    
    if (nextPageTexture == 0) {
        nextPageTexture = [self generateTexture];
    }
    
    [self drawView:view onTexture:nextPageTexture];
}
         
- (void)destroyNextPageTexture
{
    glDeleteTextures(1, &nextPageTexture);
    nextPageTexture = 0;
}


#pragma mark - View Curling Utils

- (void)curlView:(UIView *)view cylinderPosition:(CGPoint)cylinderPosition cylinderAngle:(CGFloat)cylinderAngle cylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration
{
    self.curlingView = view;
    CGRect frame = self.frame;
    
    //Reset cylinder properties, positioning it on the right side, oriented vertically
    self.cylinderPosition = CGPointMake(frame.size.width, frame.size.height/2);
    self.cylinderAngle = M_PI_2;
    self.cylinderRadius = 20;
    
    //Update the view drawn on the front of the curling page
    [self drawViewOnFrontOfPage:self.curlingView];
    
    //Start the cylinder animation
    [self setCylinderPosition:cylinderPosition animatedWithDuration:duration];
    [self setCylinderAngle:cylinderAngle animatedWithDuration:duration];
    [self setCylinderRadius:cylinderRadius animatedWithDuration:duration];
    
    //Allow interaction with back view
    //self.userInteractionEnabled = NO;
    
    //Setup the view hierarchy properly
    [self.curlingView.superview addSubview:self];
    [self.curlingView removeFromSuperview];
    
    //Start the rendering loop
    [self startAnimating];
}

- (void)uncurlAnimatedWithDuration:(NSTimeInterval)duration
{
    CGRect frame = self.frame;
    
    //Animate the cylinder back to its start position at the right side of the screen, oriented vertically
    [self setCylinderPosition:CGPointMake(frame.size.width, frame.size.height/2) animatedWithDuration:duration];
    [self setCylinderAngle:M_PI_2 animatedWithDuration:duration];
    [self setCylinderRadius:20 animatedWithDuration:duration completion:^(void) {
        //Setup the view hierarchy properly after the animation is finished
        [self.superview addSubview:self.curlingView];
        [self removeFromSuperview];
        //Stop the rendering loop since the curlView was removed from its superview nad hence won't appear
        [self stopAnimating];
        self.curlingView = nil;
    }];
}


#pragma mark - Animation and updating

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
    
    const CGFloat *color = CGColorGetComponents(self.backgroundColor.CGColor);
    glClearColor(color[0], color[1], color[2], self.opaque? 1.0: 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(program);
    
    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    
    if (!self.pageOpaque) {
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    }
    
    //Give the shader the raw values
    glUniform2f(cylinderPositionHandle, _cylinderPosition.x, _cylinderPosition.y);
    glUniform2f(cylinderDirectionHandle, cosf(_cylinderAngle), sinf(_cylinderAngle));
    glUniform1f(cylinderRadiusHandle, _cylinderRadius);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glVertexAttribPointer(positionHandle, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, x));
    glEnableVertexAttribArray(positionHandle);
    glVertexAttribPointer(texCoordHandle, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, u));
    glEnableVertexAttribArray(texCoordHandle);
    glUniformMatrix4fv(mvpHandle, 1, GL_FALSE, mvp);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, frontTexture);
    glUniform1i(samplerHandle, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glDrawElements(GL_TRIANGLES, elementCount, GL_UNSIGNED_SHORT, (void *)0);
    
    if (!self.pageOpaque) {
        glDisable(GL_BLEND);
    }
    
    //Draw the nextPage if the nextPageTexture is not 0
    if (nextPageTexture != 0) {
        glUseProgram(nextPageProgram);
        
        glUniform2f(nextPageCylinderPositionHandle, _cylinderPosition.x, _cylinderPosition.y);
        glUniform2f(nextPageCylinderDirectionHandle, cosf(_cylinderAngle), sinf(_cylinderAngle));
        glUniform1f(nextPageCylinderRadiusHandle, _cylinderRadius);
        
        glBindBuffer(GL_ARRAY_BUFFER, nextPageVertexBuffer);
        glVertexAttribPointer(nextPagePositionHandle, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, x));
        glEnableVertexAttribArray(nextPagePositionHandle);
        glVertexAttribPointer(nextPageTexCoordHandle, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, u));
        glEnableVertexAttribArray(nextPageTexCoordHandle);
        glUniformMatrix4fv(nextPageMvpHandle, 1, GL_FALSE, mvp);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, nextPageTexture);
        glUniform1i(nextPageSamplerHandle, 0);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    if (_antialiasing) {
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, sampleFramebuffer);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, framebuffer);
        glResolveMultisampleFramebufferAPPLE();
        
        GLenum attachments[] = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
#ifdef DEBUG
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"%d", error);
    }
#endif
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

