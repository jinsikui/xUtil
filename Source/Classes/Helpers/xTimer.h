

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface xTimer : NSObject

/// 创建一个timer
/// @param seconds 若fireOnStart不是YES，则start后延迟seconds开始，同时为间隔时间
/// @param queue 回调线程
/// @param fireOnStart 是否在start开始触发回调
/// @param action 回调
+ (xTimer *)timerWithIntervalSeconds:(double)seconds queue:(dispatch_queue_t)queue fireOnStart:(BOOL)fireOnStart action:(dispatch_block_t)action;

/// 创建一个回调在主线程的timer
/// @param seconds 间隔时间
/// @param fireOnStart 是否在start开始触发回调
/// @param action 回调
+ (xTimer *)timerOnMainWithIntervalSeconds:(double)seconds fireOnStart:(BOOL)fireOnStart action:(dispatch_block_t)action;

/// 创建一个回调在子线程的timer
/// @param seconds 间隔时间
/// @param fireOnStart 是否在start开始触发回调
/// @param action 回调
+ (xTimer *)timerOnGlobalWithIntervalSeconds:(double)seconds fireOnStart:(BOOL)fireOnStart action:(dispatch_block_t)action;

/// 创建一个回调在queue的timer
/// @param seconds 间隔时间
/// @param queue 回调线程
/// @param fireOnStart 是否在start开始触发回调
/// @param action 回调
- (id)initWithIntervalSeconds:(double)seconds queue:(dispatch_queue_t)queue fireOnStart:(BOOL)fireOnStart action:(dispatch_block_t)action;

@property(nonatomic, readonly) BOOL isExplicitSuspendWhenResignActive;
/**
 app锁屏，或者点home键进入后台时，这时要不要自动调用stop（然后回到前台后再自动调start）
 如果不设置，实际测试有的手机进入后台后还会继续fire timer，有的不会，但是即使设置了，
 在手机回到前台后还是会多fire一次，所以如果上层业务要求严格，最好还是在becomeActive时
 手动重置业务状态，或者在每次fire的处理中根据绝对的时间来处理而不依赖于timer的interval
 */
- (void)setExplicitSuspendWhenResignActive;

/// 开始
- (void)start;

/// 结束
- (void)stop;

@end

NS_ASSUME_NONNULL_END
