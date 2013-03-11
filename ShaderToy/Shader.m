#import "Shader.h"
#import <GLKit/GLkit.h>

NSString *loadText(NSString *name)
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

@implementation Shader
{
    unsigned program;
}

- (id)initWithVertexShader:(NSString *)vs FragmentShader:(NSString *)fs error:(NSError **)errorPtr
{
    if(self = [super init])
    {
        program = glCreateProgram();
        
        const char *vsSource = vs.UTF8String;
        const char *fsSource = fs.UTF8String;
        unsigned vsShader = glCreateShader(GL_VERTEX_SHADER);
        unsigned fsShader = glCreateShader(GL_FRAGMENT_SHADER);
        
        glShaderSource(vsShader, 1, &vsSource, 0);
        glCompileShader(vsShader);
        
        int vsStatus;
        glGetShaderiv(vsShader, GL_COMPILE_STATUS, &vsStatus);
        if(vsStatus == GL_FALSE)
        {
            char *message;
            GLint logLength;
            
            glGetShaderiv(vsShader, GL_INFO_LOG_LENGTH, &logLength);
            message = malloc(logLength);
            glGetShaderInfoLog(vsShader, logLength, &logLength, message);
            
            NSDictionary *userInfo = @{kShaderErrorKeyMessage : [NSString stringWithUTF8String:message],
                                       kShaderErrorKeyType : kShaderErrorTypeVertex};
            *errorPtr = [NSError errorWithDomain:@"compile error"
                                            code:0
                                        userInfo:userInfo];
            free(message);
            goto EndOfInit;
        }
        
        glShaderSource(fsShader, 1, &fsSource, 0);
        glCompileShader(fsShader);
        
        int fsStatus;
        glGetShaderiv(fsShader, GL_COMPILE_STATUS, &fsStatus);
        if(fsStatus == GL_FALSE)
        {
            char *message;
            GLint logLength;
            
            glGetShaderiv(fsShader, GL_INFO_LOG_LENGTH, &logLength);
            message = malloc(logLength);
            glGetShaderInfoLog(fsShader, logLength, &logLength, message);
            
            NSDictionary *userInfo = @{kShaderErrorKeyMessage : [NSString stringWithUTF8String:message],
                                       kShaderErrorKeyType : kShaderErrorTypeVertex};
            *errorPtr = [NSError errorWithDomain:@"compile error"
                                            code:0
                                        userInfo:userInfo];
            
            free(message);
            goto EndOfInit;
        }
        
        glAttachShader(program, vsShader);
        glAttachShader(program, fsShader);
        glLinkProgram(program);
        
//#if defined(DEBUG)
//        {
//            GLint logLength;
//            glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
//            if (logLength > 0) {
//                GLchar *log = (GLchar *)malloc(logLength);
//                glGetProgramInfoLog(program, logLength, &logLength, log);
//                NSLog(@"link log:\n%s", log);
//                free(log);
//            }
//        }
//#endif
        
    EndOfInit:
        
        glDetachShader(program, vsShader);
        glDetachShader(program, fsShader);
        glDeleteShader(vsShader);
        glDeleteShader(fsShader);
    }
    return self;
}
- (void)dealloc
{
    glDeleteProgram(program);
}
- (void)bind
{
    glUseProgram(program);
}
- (void)unbind
{
    glUseProgram(0);
}
- (void)uniform:(NSString *)name texture:(unsigned)tex
{
    glUniform1i(glGetUniformLocation(program, [name UTF8String]), tex);
}
- (void)uniform:(NSString *)name flt:(float)flt
{
    glUniform1f(glGetUniformLocation(program, [name UTF8String]), flt);
}
- (void)uniform:(NSString *)name vec2:(GLKVector2)vec
{
    glUniform2f(glGetUniformLocation(program, [name UTF8String]), vec.x, vec.y);
}
- (void)uniform:(NSString *)name vec3:(GLKVector3)vec
{
    glUniform3f(glGetUniformLocation(program, [name UTF8String]), vec.x, vec.y, vec.z);
}
- (void)uniform:(NSString *)name vec4:(GLKVector4)vec
{
    glUniform4f(glGetUniformLocation(program, [name UTF8String]), vec.x, vec.y, vec.z, vec.w);
}
- (void)uniform:(NSString *)name mat3x3:(GLKMatrix3)mat
{
    glUniformMatrix3fv(glGetUniformLocation(program, [name UTF8String]), 1, GL_FALSE, mat.m);
}
- (void)uniform:(NSString *)name mat4x4:(GLKMatrix4)mat
{
    glUniformMatrix4fv(glGetUniformLocation(program, [name UTF8String]), 1, GL_FALSE, mat.m);
}
- (int)attribLocation:(NSString *)name
{
    return glGetAttribLocation(program, [name UTF8String]);
}
@end
