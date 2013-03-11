#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>

static NSString *const kShaderErrorKeyMessage = @"message";
static NSString *const kShaderErrorKeyType = @"shadertype";
static NSString *const kShaderErrorTypeVertex = @"vertex";
static NSString *const kShaderErrorTypeFragment = @"vertex";


NSString *loadText(NSString *name);

@interface Shader : NSObject
- (id)initWithVertexShader:(NSString *)vs FragmentShader:(NSString *)fs error:(NSError **)errorPtr;

- (void)bind;
- (void)unbind;

- (void)uniform:(NSString *)name texture:(unsigned)tex;
- (void)uniform:(NSString *)name flt:(float)flt;
- (void)uniform:(NSString *)name vec2:(GLKVector2)vec;
- (void)uniform:(NSString *)name vec3:(GLKVector3)vec;
- (void)uniform:(NSString *)name vec4:(GLKVector4)vec;
- (void)uniform:(NSString *)name mat3x3:(GLKMatrix3)mat;
- (void)uniform:(NSString *)name mat4x4:(GLKMatrix4)mat;

- (int)attribLocation:(NSString *)name;
@end
