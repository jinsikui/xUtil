

#import <Foundation/Foundation.h>
#import "xAVPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface xAVPlayerAgent : NSObject

/// 音频url
@property(nonatomic,readonly) NSURL          *url;
/// 当前状态
@property(nonatomic,readonly) xAVPlayerState    state;
/// 当前时长
@property(nonatomic,readonly) NSTimeInterval    curTime;
/// 总时长
@property(nonatomic,readonly) NSTimeInterval    duration;

/// 获取单例
+ (instancetype)shared;
/// 播放
/// @param url 音频url
- (void)play:(NSURL *)url;
/// 暂停
- (void)pause;
/// 停止
- (void)stop;
/// 播放特定时间
/// @param time 时间
- (void)seek:(NSTimeInterval)time;
/// 添加代理
/// @param listener 不需要remove，不会强引用
- (void)registerListener:(NSObject<xAVPlayerDelegate>*)listener;

@end

NS_ASSUME_NONNULL_END
