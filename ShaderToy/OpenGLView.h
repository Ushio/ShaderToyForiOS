#import <UIKit/UIKit.h>

@protocol OpenGLViewDelegate;
@interface OpenGLView : UIView
- (id) initWithFrame:(CGRect)frame;

//フレーム描画の開始と停止
- (void)startRendering;
- (void)stopRendering;

@property (nonatomic, readonly)BOOL animating;

//フレームバッファのサイズ
@property (nonatomic, readonly)int glBufferWidth;
@property (nonatomic, readonly)int glBufferHeight;

//描画コールバック
@property (weak, nonatomic)id<OpenGLViewDelegate> glViewDelegate;

- (void)setupFrameBuffer;

@end

@protocol OpenGLViewDelegate<NSObject>
@required
- (void)render:(CADisplayLink *)sender;
@end

/*
 プチメモ CADisplayLink
 sender.timestamp 経過時間
*/