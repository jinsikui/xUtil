

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kRequireSignOutToast = @"xNotice.RequireSignOutToast";

@interface NSObject (xNotice)

/// 不发通知
@property (nonatomic, assign) BOOL x_notice_disable;

@end

@interface xNotice : NSObject

/// 获取单例
+ (instancetype)shared;

/// 注册完成加载事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerAppFinishLaunching:(id)lifeIndicator action:(void(^)(id __nullable))action;

/// 注册app前台事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerAppWillEnterForeground:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册app活跃事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerAppBecomeActive:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册app将不活跃事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerAppWillResignActive:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册app进入后台事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerAppEnterBackground:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册app将被销毁事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerAppWillTerminate:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册app切换音频路由事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerAppAudioSessionRouteChange:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册事件
/// @param eventName 事件名称
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerEvent:(NSString*)eventName lifeIndicator:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册登出事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerRequireSignOut:(id)lifeIndicator action:(void (^)(id __nullable))action;

/// 注册登录事件
/// @param lifeIndicator 传self就行
/// @param action 回调
- (void)registerSignInWith:(id)lifeIndicator action:(void (^)(id __nullable))action;

#pragma mark - post events

/// 触发事件
/// @param eventName 触发事件名称
/// @param userInfo 参数
- (void)postEvent:(NSString*)eventName userInfo:(NSDictionary<NSString*, id>* __nullable)userInfo;

/// 登出
/// @param toast 提示语
- (void)postRequireSignOutWithToast:(NSString* __nullable)toast;

/// 登录
- (void)postSignIn;
@end

NS_ASSUME_NONNULL_END

