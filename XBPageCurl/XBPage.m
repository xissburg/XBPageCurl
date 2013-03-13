//
//  XBPage.m
//  XBPageCurl
//
//  Created by xissburg on 3/12/13.
//
//

#import "XBPage.h"
#import "CGPointAdditions.h"
#import "XBAnimation.h"
#import <QuartzCore/QuartzCore.h>

#define kCylinderPositionAnimationName @"cylinderPosition"
#define kCylinderDirectionAnimationName @"cylinderDirection"
#define kCylinderRadiusAnimationName @"cylinderRadius"

@interface XBPage ()

@property (nonatomic, weak) EAGLContext *context;
@property (nonatomic, weak) XBAnimationManager *animationManager;

@end

@implementation XBPage

- (id)initWithContext:(EAGLContext *)context animationManager:(XBAnimationManager *)animationManager frame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.context = context;
        self.animationManager = animationManager;
        self.cylinderPosition = CGPointMake(self.bounds.size.width, self.bounds.size.height/2);
        self.cylinderAngle = M_PI_2;
        self.cylinderRadius = 32;
        self.frame = frame;
        
        CGFloat scale = [[UIScreen mainScreen] scale];
        _textureWidth = (GLuint)(self.frame.size.width*scale);
        _textureHeight = (GLuint)(self.frame.size.height*scale);
        _frontTexture = [self generateTexture];
    }
    return self;
}

#pragma mark - Properties

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration
{
    [self setCylinderPosition:cylinderPosition animatedWithDuration:duration completion:nil];
}

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    [self setCylinderPosition:cylinderPosition animatedWithDuration:duration interpolator:XBAnimationInterpolatorEaseInOut completion:completion];
}

- (void)setCylinderPosition:(CGPoint)cylinderPosition animatedWithDuration:(NSTimeInterval)duration interpolator:(double (^)(double t))interpolator completion:(void (^)(void))completion
{
    CGPoint p0 = self.cylinderPosition;
    __weak XBPage *weakSelf = self;
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderPositionAnimationName duration:duration update:^(double t) {
        weakSelf.cylinderPosition = CGPointMake((1 - t)*p0.x + t*cylinderPosition.x, (1 - t)*p0.y + t*cylinderPosition.y);
    } completion:completion interpolator:interpolator];
    [self.animationManager runAnimation:animation];
}

- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration
{
    [self setCylinderAngle:cylinderAngle animatedWithDuration:duration completion:nil];
}

- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    [self setCylinderAngle:cylinderAngle animatedWithDuration:duration interpolator:XBAnimationInterpolatorEaseInOut completion:completion];
}

- (void)setCylinderAngle:(CGFloat)cylinderAngle animatedWithDuration:(NSTimeInterval)duration interpolator:(double (^)(double t))interpolator completion:(void (^)(void))completion
{
    double a0 = _cylinderAngle;
    double a1 = cylinderAngle;
    __weak XBPage *weakSelf = self;
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderDirectionAnimationName duration:duration update:^(double t) {
        weakSelf.cylinderAngle = (1 - t)*a0 + t*a1;
    } completion:completion interpolator:interpolator];
    [self.animationManager runAnimation:animation];
}

- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration
{
    [self setCylinderRadius:cylinderRadius animatedWithDuration:duration completion:nil];
}

- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion
{
    [self setCylinderRadius:cylinderRadius animatedWithDuration:duration interpolator:XBAnimationInterpolatorEaseInOut completion:completion];
}

- (void)setCylinderRadius:(CGFloat)cylinderRadius animatedWithDuration:(NSTimeInterval)duration interpolator:(double (^)(double t))interpolator completion:(void (^)(void))completion
{
    CGFloat r = self.cylinderRadius;
    __weak XBPage *weakSelf = self;
    XBAnimation *animation = [XBAnimation animationWithName:kCylinderRadiusAnimationName duration:duration update:^(double t) {
        weakSelf.cylinderRadius = (1 - t)*r + t*cylinderRadius;
    } completion:completion interpolator:interpolator];
    [self.animationManager runAnimation:animation];
}

#pragma mark - Methods

- (BOOL)pointInside:(CGPoint)point
{
    if (CGRectContainsPoint(self.frame, point)) {
        CGPoint v = CGPointMake(-sinf(self.cylinderAngle), cosf(self.cylinderAngle));
        CGPoint w = CGPointSub(point, CGPointSub(self.cylinderPosition, CGPointMul(v, self.cylinderRadius)));
        CGFloat dot = CGPointDot(v, w);
        return dot > 0;
    }
    
    return NO;
}

#pragma mark - Textures

- (void)drawOnTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height drawBlock:(void (^)(CGContextRef context))drawBlock
{
    [EAGLContext setCurrentContext:self.context];
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = self.textureWidth * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, self.textureWidth, self.textureHeight, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGRect r = CGRectMake(0, 0, width, height);
    CGContextClearRect(context, r);
    CGContextSaveGState(context);
    
    drawBlock(context);
    
    CGContextRestoreGState(context);
    
    GLubyte *textureData = (GLubyte *)CGBitmapContextGetData(context);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.textureWidth, self.textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    glBindTexture(GL_TEXTURE_2D, self.frontTexture); // Keep the frontTexture bound
    
    CGContextRelease(context);
}

- (void)drawImage:(UIImage *)image onTexture:(GLuint)texture
{
    [self drawImage:image onTexture:texture flipHorizontal:NO];
}

- (void)drawImage:(UIImage *)image onTexture:(GLuint)texture flipHorizontal:(BOOL)flipHorizontal
{
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    
    [self drawOnTexture:texture width:width height:height drawBlock:^(CGContextRef context) {
        if (flipHorizontal) {
            CGContextTranslateCTM(context, width, height);
            CGContextScaleCTM(context, -1, -1);
        }
        else {
            CGContextTranslateCTM(context, 0, height);
            CGContextScaleCTM(context, 1, -1);
        }
        
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    }];
}

- (void)drawView:(UIView *)view onTexture:(GLuint)texture
{
    [self drawView:view onTexture:texture flipHorizontal:NO];
}

- (void)drawView:(UIView *)view onTexture:(GLuint)texture flipHorizontal:(BOOL)flipHorizontal
{
    [self drawOnTexture:texture width:view.bounds.size.width height:view.bounds.size.height drawBlock:^(CGContextRef context) {
        CGFloat scale = [[UIScreen mainScreen] scale];
        if (flipHorizontal) {
            CGContextTranslateCTM(context, view.bounds.size.width*scale, 0);
            CGContextScaleCTM(context, -scale, scale);
        }
        else {
            CGContextScaleCTM(context, scale, scale);
        }
        
        [view.layer renderInContext:context];
    }];
}

- (void)drawImageOnFrontOfPage:(UIImage *)image
{
    [EAGLContext setCurrentContext:self.context];
    [self drawImage:image onTexture:self.frontTexture];
    
    //Force a redraw to avoid glitches
    //[self draw:self.displayLink];
}

- (void)drawViewOnFrontOfPage:(UIView *)view
{
    [EAGLContext setCurrentContext:self.context];
    [self drawView:view onTexture:self.frontTexture];
    
    //Force a redraw to avoid glitches
    //[self draw:self.displayLink];
}

- (void)drawImageOnBackOfPage:(UIImage *)image
{
    [EAGLContext setCurrentContext:self.context];
    
    if (image == nil) {
        [self destroyBackTexture];
        return;
    }
    
    if (self.backTexture == 0) {
        _backTexture = [self generateTexture];
    }
    
    [self drawImage:image onTexture:self.backTexture flipHorizontal:YES];
}

- (void)drawViewOnBackOfPage:(UIView *)view
{
    [EAGLContext setCurrentContext:self.context];
    
    if (view == nil) {
        [self destroyBackTexture];
        return;
    }
    
    if (self.backTexture == 0) {
        _backTexture = [self generateTexture];
    }
    
    [self drawView:view onTexture:self.backTexture flipHorizontal:YES];
}

- (GLuint)generateTexture
{
    [EAGLContext setCurrentContext:self.context];
    GLuint tex;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    return tex;
}

- (void)destroyBackTexture
{
    [EAGLContext setCurrentContext:self.context];
    glDeleteTextures(1, &_backTexture);
    _backTexture = 0;
}

- (void)destroyTextures
{
    glDeleteTextures(1, &_frontTexture);
    _frontTexture = 0;
    
    [self destroyBackTexture];
}

@end
