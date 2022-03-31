

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface xKeychainStore : NSObject

@property(nonatomic, readonly) NSString *name;

/// 默认存储service
+ (instancetype)defaultStore;

/// 通过name创建一个service，每一个name对应keychain中的一个service
+ (instancetype)storeWithName:(NSString*)name;

/// 通过key取数据
/// @param key 给定key
- (id _Nullable)objectForKeyedSubscript:(NSString*)key;

/// 存数据
/// @param obj 数据
/// @param key 给定key
- (void)setObject:(id<NSCoding> _Nullable)obj forKeyedSubscript:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
