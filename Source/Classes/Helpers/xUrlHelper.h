

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface xUrlHelper : NSObject

/// 去掉不符合url编码的特殊字符
/// @param input 字符串
+ (NSString *)urlEncode:(NSString *)input;

/// url解码
/// @param input 字符串
+ (NSString *)urlDecode:(NSString *)input;

/// 将query参数添加到字符串中
/// @param input 字符串
/// @param params query参数
+ (NSString *)mergeToInput:(NSString *)input queryParams:(NSDictionary *)params;

/// 在给定url的query中找到第一个key相同的
/// @param url 给定rul
/// @param name key
+ (NSString * __nullable)queryValueIn:(NSString *)url name:(NSString *)name;

/// url的主机地址
+ (NSString * __nullable)hostFor:(NSString *)url;

/// url的路径
+ (NSString * __nullable)pathFor:(NSString *)url;

/// url的query
+ (NSDictionary<NSString *, NSString *> * __nullable)paramsFor:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
