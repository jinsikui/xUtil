

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum xSocketStatus{
    xSocketStatusClose = 0,
    xSocketStatusOpen,
    xSocketStatusFail
}xSocketStatus;

@protocol xSocketServiceDelegate<NSObject>

@optional

/// 获取到数据的回调
/// @param data 可能是NSString也可能是NSData（使用protobuf时）
/// @param userInfo 创建时传入的数据
- (void)socketGotData:(id)data userInfo:(NSDictionary* __nullable)userInfo;

/// 链接到服务器成功
/// @param userInfo 创建时传入的数据
- (void)socketConnectedWithUserInfo:(NSDictionary* __nullable)userInfo;

/// 关闭连接（会自动重试）
/// @param info "code":int,"reason":NSString*,"server":NSString*
- (void)socketClosedWithInfo:(NSDictionary*)info;

/// 发生错误
/// @param info "code":int,"reason":NSString*,"server":NSString*
- (void)socketErrorWithInfo:(NSDictionary*)info;

@end

@interface xSocketService : NSObject

/// 回调时可传回的信息
@property(nonatomic) NSDictionary *userInfo;
/// 创建实例
/// @param servers 服务器数组
/// @param userInfo 回调时可传回的信息
- (instancetype)initWithServers:(NSArray<NSString*>*)servers userInfo:(NSDictionary* __nullable)userInfo;
/// 服务器数组
@property(nonatomic) NSArray<NSString*> *servers;
/// 代理
@property(nonatomic,weak) id<xSocketServiceDelegate> delegate;
/// 当前状态
@property(nonatomic,readonly) xSocketStatus status;
/// 开启连接
- (void)open;
/// 关闭连接
- (void)close;

@end

NS_ASSUME_NONNULL_END
