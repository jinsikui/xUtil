

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum xAVAudioRecorderState {
    xAVAudioRecorderStateNone = 0,
    xAVAudioRecorderStateRecording = 1,
    xAVAudioRecorderStatePaused = 2,
    xAVAudioRecorderStateFinished = 3
} xAVAudioRecorderState;

@protocol xAVAudioRecorderDelegate
@optional
/// 录音器状态改变回调
/// @param state 当前状态
/// @param time 当前时间
- (void)xAVAudioRecorderOnStateChanged:(xAVAudioRecorderState)state recordingTime:(NSTimeInterval)time;
/// 录音器出错回调
/// @param error 错误
- (void)xAVAudioRecorderOnError:(NSError*)error;
@end

@interface xAVAudioRecorder : NSObject
/// 录音存储位置
@property(nonatomic) NSString *filePath;
/// 当前状态
@property(nonatomic) xAVAudioRecorderState state;
/// 代理
@property(nonatomic, weak, nullable) NSObject<xAVAudioRecorderDelegate> *delegate;
/// 当前时长
@property(nonatomic, readonly) NSTimeInterval curTime;
/// 同curTime
@property(nonatomic, readonly) NSTimeInterval duration;
/// 通过录音位置创建录音器
/// @param filePath 录音存储位置
- (instancetype)initWithFilePath:(NSString*)filePath;
/// 准备录音，录音前调用，会注册打断事件
- (void)prepareForRecord;
/// 开始录音
- (void)record;
/// 暂停录音
- (void)pause;
/// 停止录音
- (void)stop;
/// 销毁
- (void)dispose;
@end

NS_ASSUME_NONNULL_END
