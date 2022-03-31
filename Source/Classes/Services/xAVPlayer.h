

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum xAVPlayerState {
    xAVPlayerStateNone = 0,
    xAVPlayerStateLoading = 1,
    xAVPlayerStatePlaying = 2,
    xAVPlayerStatePaused = 3,
    xAVPlayerStateFinished = 4
} xAVPlayerState;

@protocol xAVPlayerDelegate
@optional
/// 播放器状态改变
/// @param state 当前状态
/// @param curTime 当前时长
/// @param duration 总时长
- (void)xAVPlayerOnStateChanged:(xAVPlayerState)state curTime:(NSTimeInterval)curTime duration:(NSTimeInterval)duration;
/// 播放器发生错误
/// @param error 错误
- (void)xAVPlayerOnError:(NSError*)error;
@end

@interface xAVPlayer : NSObject
/// 音频url
@property(nonatomic) NSURL *url;
/// 播放器状态
@property(nonatomic) xAVPlayerState state;
/// 代理
@property(nonatomic, weak, nullable) NSObject<xAVPlayerDelegate> *delegate;
/// 当前时长
@property(nonatomic) NSTimeInterval curTime;
/// 总时长
@property(nonatomic, readonly) NSTimeInterval duration;
/// 通过音频创建一个播放器
/// @param url 音频url
- (instancetype)initWithUrl:(NSURL*)url;
/// 准备播放，调用play前调用，会监听输出设备变化和打断事件
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
