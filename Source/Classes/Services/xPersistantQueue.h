

#import <Foundation/Foundation.h>
#if __has_include(<FBLPromises/FBLPromises.h>)
#import <FBLPromises/FBLPromises.h>
#else
#import "FBLPromises.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class xPersistantQueue;

typedef void(^xPersistantQueueProcessCallback)(NSObject *data, xPersistantQueue *queue);


/// 持久化串行队列，保证数据串行处理（处理完一个再处理下一个）
/// 底层采用数据库存储数据
@interface xPersistantQueue : NSObject


/// 初始化方法
/// @param name name作为documents文件夹中数据库的文件名
+ (instancetype)queueWithName:(NSString*)name;

/// 初始化方法
/// @param path 底层数据库的文件路径
+ (instancetype)queueWithPath:(NSString*)path;
+ (instancetype)alloc NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


/// 处理数据的回调，在global线程触发，在回调中可以自由的调用inqueueData或者completeProcessData（也可以不在回调中调这两个方法，上层可自由处理）
/// 如果不设置，inqueue的数据会一直保存在队列里，等待设置后触发回调
@property(nonatomic,copy) xPersistantQueueProcessCallback _Nullable processCallback;


/// 向队列添加数据，可在任意时刻调用
/// @param data 数据
- (void)inqueueData:(NSObject<NSCoding> *)data;


/// 声明一次处理完毕（调用后才会处理下一条数据）
/// @param data 为空时不会从队列删除数据，这样下一次处理还会重新处理之前的数据，
/// data为空时不会立刻触发下一次处理，会等下一次inqueueData后再触发，
/// data不为空时会从队列删除数据并立刻触发下一次处理
- (void)completeProcessData:(NSObject *_Nullable)data;

- (void)deleteAll;

@end

NS_ASSUME_NONNULL_END
