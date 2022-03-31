

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum xAVAudioPlayerState {
    xAVAudioPlayerStateNone = 0,
    xAVAudioPlayerStatePlaying = 1,
    xAVAudioPlayerStatePaused = 2,
    xAVAudioPlayerStateFinished = 3
} xAVAudioPlayerState;

/// 在swift里识别不了xAudioPlayerDelegate这个名字，只能起这个不规范的名字了
@protocol audioPlayerDelegate
@optional
/// 播放器状态改变
/// @param state 当前状态
/// @param curTime 当前时间
/// @param duration 总时长
- (void)playerOnStateChanged:(xAVAudioPlayerState)state curTime:(NSTimeInterval)curTime duration:(NSTimeInterval)duration;
/// 播放器出错
/// @param error 错误
- (void)playerOnError:(NSError *)error;
@end

@interface xAVAudioPlayer : NSObject
/// 音频url
@property(nonatomic) NSURL *url;
/// 播放器状态
@property(nonatomic) xAVAudioPlayerState state;
/// 代理
@property(nonatomic, weak, nullable) NSObject<audioPlayerDelegate> *delegate;
/// 当前时间
@property(nonatomic,readonly) NSTimeInterval curTime;
/// 总时长
@property(nonatomic,readonly) NSTimeInterval duration;
/// 通过url创建播放器
/// @param url 音频url
- (instancetype)initWithUrl:(NSURL *)url;
/// 准备播放，play前调用，会添加打断及输出设备变化的监听
- (void)prepareForPlay;
/// 播放
- (void)play;
/// 暂停
- (void)pause;
/// 停止
- (void)stop;
/// 播放特定时间
/// @param time 时间
- (void)seek:(NSTimeInterval)time;
/// 销毁
- (void)dispose;
@end

NS_ASSUME_NONNULL_END
