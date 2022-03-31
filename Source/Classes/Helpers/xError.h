

#import <Foundation/Foundation.h>

#define X_ERROR_DOMAIN @"X_ERROR"

NS_ASSUME_NONNULL_BEGIN

@interface xError : NSError

/// 错误信息
@property(nonatomic, nullable) NSString *msg;

/// 初始化
/// @param code 错误码
/// @param msg 错误信息
+ (instancetype)errorWithCode:(NSInteger)code msg:(NSString * _Nullable)msg;

@end

NS_ASSUME_NONNULL_END
