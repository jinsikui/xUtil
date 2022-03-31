

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface xStore : NSObject

/// 默认文件夹
+ (instancetype)defaultStore;

/// 通过name创建一个文件夹
+ (instancetype)storeByName:(NSString*)name;

/// 取出key所对应的数据
/// @param key 给定key
- (id _Nullable)objectForKeyedSubscript:(NSString*)key;

/// 存储数据
/// @param obj 数据
/// @param key 给定key
- (void)setObject:(id<NSCoding> _Nullable)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
