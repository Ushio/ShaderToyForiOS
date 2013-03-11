#import "OpenGLView.h"

#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation OpenGLView
{
    EAGLContext *mainContext;
    unsigned mainFrameBuffer;
    unsigned mainColorRenderBuffer;
    unsigned mainDepthRenderBuffer;
    int mainBufferWidth, mainBufferHeight;
    CADisplayLink *displayLink;
    BOOL _animating;
}

+ (Class) layerClass { return [CAEAGLLayer class]; }
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
        glLayer.contentsScale = [UIScreen mainScreen].scale;
        glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(NO),
                                       kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
        glLayer.opaque = YES;
        
        //コンテキスト
        mainContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if(!mainContext)
            abort();
        
        if(![EAGLContext setCurrentContext:mainContext])
            abort();
        
        _animating = NO;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //CAEAGLLayer
        CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
        glLayer.contentsScale = [UIScreen mainScreen].scale;
        glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(NO),
                                      kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        glLayer.opaque = YES;
        
        //コンテキスト
        mainContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSAssert(mainContext, @"");
        
        if(![EAGLContext setCurrentContext:mainContext])
            NSAssert(0, @"");
        
        _animating = NO;
    }
    return self;
}
- (void)dealloc
{
    [self shutdownFrameBuffer];
}
- (int)glBufferWidth { return mainBufferWidth; }
- (int)glBufferHeight { return mainBufferHeight; }

- (void)setupFrameBuffer
{
    //レンダーバッファ
    glGenRenderbuffers(1, &mainColorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, mainColorRenderBuffer);
    [mainContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &mainBufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &mainBufferHeight);
    
    //深度バッファ 深度バッファをバインドしたらカラーバッファをバインドしなおさないとだめなようだ
    glGenRenderbuffers(1, &mainDepthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, mainDepthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, mainBufferWidth, mainBufferHeight);
    
    //フレームバッファ
    glGenFramebuffers(1, &mainFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, mainFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, mainColorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, mainDepthRenderBuffer);
    
    unsigned status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"");
    
    glViewport(0, 0, mainBufferWidth, mainBufferHeight);
}
- (void)shutdownFrameBuffer
{
    if(mainColorRenderBuffer)
    {
        glDeleteRenderbuffers(1, &mainColorRenderBuffer);
        mainFrameBuffer = 0;
    }
    if(mainDepthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &mainDepthRenderBuffer);
        mainFrameBuffer = 0;
    }
    if(mainFrameBuffer)
    {
        glDeleteFramebuffers(1, &mainFrameBuffer);
        mainFrameBuffer = 0;
    }
}
- (void)layoutSubviews
{
    [self shutdownFrameBuffer];
    [self setupFrameBuffer];
}
- (BOOL)animating
{
    return _animating;
}
- (void)startRendering
{
    if(!_animating)
    {
        displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(render:)];
        displayLink.frameInterval = 1;
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _animating = YES;
    }
}
- (void)stopRendering
{
    if(_animating)
    {
        [displayLink invalidate];
        displayLink = nil;
        _animating = NO;
    }
}

- (void)render:(CADisplayLink *)sender 
{
    [EAGLContext setCurrentContext:mainContext];
    glBindRenderbuffer(GL_RENDERBUFFER, mainColorRenderBuffer);
    
    [self.glViewDelegate render:sender];

    [mainContext presentRenderbuffer:GL_RENDERBUFFER];
}
@end
