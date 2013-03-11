#import "ViewController.h"
#import "Shader.h"

@implementation ViewController
{
    IBOutlet OpenGLView *openGLView;
    Shader *shader;
    
    NSDate *beginTime;
    GLKVector4 mouse;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    openGLView.glViewDelegate = self;
    [openGLView startRendering];
    
    /**
     example
     */
    
    NSError *error;
    shader = [[Shader alloc] initWithVertexShader:loadText(@"shader.vs")
                                   FragmentShader:loadText(@"shader.fs")
                                            error:&error];
    if(error)
    {
        NSLog(@"%@", error);
    }
    
    beginTime = [NSDate date];
    mouse = GLKVector4Make(0, 0, 0, 1);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)render:(CADisplayLink *)sender
{
    glClearColor(1.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    typedef struct{
        GLKVector2 position;
    }Vertex;
    
    Vertex vertices[] =
    {
        {-1.0f,  1.0f},
        {-1.0f, -1.0f},
        { 1.0f, -1.0f},
        { 1.0f,  1.0f},
    };
    
    glEnableVertexAttribArray([shader attribLocation:@"position"]);
    glVertexAttribPointer([shader attribLocation:@"position"], 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), &vertices[0].position);
    
    /*bind -> uniform*/
    [shader bind];
    [shader uniform:@"iGlobalTime" flt:[[NSDate date] timeIntervalSinceDate:beginTime]];
    [shader uniform:@"iResolution" vec3:GLKVector3Make(openGLView.glBufferWidth, openGLView.glBufferHeight, 0)];
    [shader uniform:@"iMouse" vec4:mouse];
    
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    [shader unbind];
    
    glDisableVertexAttribArray([shader attribLocation:@"position"]);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:openGLView];
    mouse = GLKVector4Make(point.x * [UIScreen mainScreen].scale, point.y * [UIScreen mainScreen].scale, 0, 1);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:openGLView];
    mouse = GLKVector4Make(point.x * [UIScreen mainScreen].scale, point.y * [UIScreen mainScreen].scale, 0, 1);
}

@end
