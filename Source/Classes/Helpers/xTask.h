/*******************************************************************************
    xTask 轻量好用的任务管理组件
    定义: task是指一个实现了xTaskProtocol协议的实例，代表一个会在未来某个时刻结束的过程
    原则上，一个task可以cancel，但不保证cancel成功，这由具体实现决定
    已经实现了以下几种task:
    xAsyncTask: 在某个dispatch queue上执行一个block，可以设置延迟时间，在延迟结束前可以cancel成功
    xDelayTask: 代表一个延迟过程，在延迟结束前可以cancel成功，常作为xCompositeTask的子task
    xCustomTask: 通过一个block来定义task，可自由的决定task何时complete，何时cancel
    xCompositeTask: 传入一组子task和一个回调函数，可设置all或any两种类型，当任意(any)一个子task结束(status == canceled || status == completed)
    或当全部(all)子task结束时，xCompositeTask结束，触发回调函数。每个子task本身也可以是一个xCompositeTask

    应用例子:比如打开红包，希望开红包动效至少持续2秒，可以把请求api的过程封装成一个xCustomTask，同时再创建一个延迟2秒的xDelayTask，两个一起组成一个all类型的xCompositeTask
    这个xCompositeTask可以来实现开红包动效至少持续2秒，即使api在2秒内就返回了。
*******************************************************************************/

#import <Foundation/Foundation.h>

typedef enum xTaskStatus{
    xTaskStatusInitial = 0,
    xTaskStatusExecuting,
    xTaskStatusCanceled,
    xTaskStatusCompleted
} xTaskStatus;

NS_ASSUME_NONNULL_BEGIN

@interface xTaskHandle : NSObject

/// 任务状态
@property(nonatomic) xTaskStatus status;
/// 任务执行结果
@property(nonatomic,strong,nullable) id result;
/// 错误信息
@property(nonatomic,strong,nullable) NSError *error;

/// 取消
- (void)cancel;
/// 取消
/// @param result 执行结果
/// @param error 错误信息
- (void)cancel:(id _Nullable)result error:(NSError * _Nullable)error;
/// 完成
- (void)complete;
/// 完成
/// @param result 执行结果
- (void)complete:(id _Nullable)result;
/// 完成
/// @param result 执行结果
/// @param error 错误信息
- (void)complete:(id _Nullable)result error:(NSError * _Nullable)error;

@end

@protocol xTaskProtocol

/// 任务处理
@property(nonatomic,readonly) xTaskHandle *handle;
/// 任务状态
@property(nonatomic,readonly) xTaskStatus status;
/// 执行任务
- (void)execute;

@end

@interface xAsyncTask : NSObject<xTaskProtocol>
/// 任务处理
@property(nonatomic,readonly) xTaskHandle *handle;
/// 任务状态
@property(nonatomic,readonly) xTaskStatus status;
/// 执行队列
@property(nonatomic,strong) dispatch_queue_t     queue;
/// 延迟时间
@property(nonatomic) double               afterSecs;
/// 执行完毕回调
@property(nonatomic) void(^task)(void);
/// 初始化
/// @param queue 队列
/// @param afterSecs 延迟
/// @param task 完成回调
- (instancetype)initWithQueue:(dispatch_queue_t)queue after:(double)afterSecs task:(void(^)(void))task;
/// 取消
- (void)cancel;

@end

@interface xDelayTask : NSObject<xTaskProtocol>

/// 任务处理
@property(nonatomic,readonly) xTaskHandle *handle;
/// 任务状态
@property(nonatomic,readonly) xTaskStatus status;
/// 延迟时间
@property(nonatomic) double   delaySecs;
/// 初始化
/// @param delaySecs 延迟时间
- (instancetype)initWithDelaySecs:(double)delaySecs;
/// 取消
- (void)cancel;

@end

@interface xCustomTask : NSObject<xTaskProtocol>

/// 任务处理
@property(nonatomic,readonly) xTaskHandle *handle;
/// 任务状态
@property(nonatomic,readonly) xTaskStatus status;
/// 回调
@property(nonatomic) void (^handler)(xTaskHandle*);
/// 初始化
/// @param handler 完成回调
- (instancetype)initWithHandler:(void(^)(xTaskHandle*))handler;

@end

typedef enum xCompositeTaskType{
    xCompositeTaskTypeAll = 1,
    xCompositeTaskTypeAny = 2
}xCompositeTaskType;

@interface xCompositeTask : NSObject<xTaskProtocol>

/// 任务处理
@property(nonatomic,readonly) xTaskHandle *handle;
/// 任务状态
@property(nonatomic,readonly) xTaskStatus status;
/// 组合种类：all全部 any任意一个完成则完成
@property(nonatomic) xCompositeTaskType     type;
/// 任务数组
@property(nonatomic,strong) NSArray<id<xTaskProtocol>> *tasks;
/// 完成回调
@property(nonatomic) void (^callback)(NSArray<id<xTaskProtocol>>*);
/// 初始化
/// @param type 组合种类
/// @param tasks 组合数组
/// @param callback 完成回调
- (instancetype)initWithType:(xCompositeTaskType)type tasks:(NSArray<id<xTaskProtocol>>*)tasks callback:(void(^)(NSArray<id<xTaskProtocol>>*))callback;
/// 取消
- (void)cancel;

@end


/**
 快捷调用方式
 **/
@interface xTask : NSObject

/// 如果在主线程就同步执行，否则异步主线程执行
+ (void)executeMain:(void(^)(void))task;

/// 异步主线程，会立刻执行
+ (void)asyncMain:(void(^)(void))task;

/// 异步非主线程，会立刻执行
+ (void)asyncGlobal:(void(^)(void))task;

/// 异步，会立刻执行
/// @param queue 执行线程
/// @param task 任务
+ (void)async:(dispatch_queue_t)queue task:(void(^)(void))task;

/// 异步主线程延迟执行，会立刻开始算延迟
/// @param seconds 延迟秒数
/// @param task 任务
+ (xTaskHandle*)asyncMainAfter:(double)seconds task:(void(^)(void))task;

/// 异步非主线程延迟执行，会立刻开始算延迟
/// @param seconds 延迟秒数
/// @param task 任务
+ (xTaskHandle*)asyncGlobalAfter:(double)seconds task:(void(^)(void))task;

/// 异步queue延迟执行，会立刻开始算延迟
/// @param queue 执行线程
/// @param seconds 延迟秒数
/// @param task 任务
+ (xTaskHandle*)async:(dispatch_queue_t)queue after:(double)seconds task:(void(^)(void))task;

/// 创建一个异步queue执行任务
/// @param queue 执行线程
/// @param task 回调
+ (xAsyncTask*)asyncTaskWithQueue:(dispatch_queue_t)queue task:(void(^)(void))task;

/// 创建一个异步queue延迟执行任务
/// @param queue 执行线程
/// @param seconds 延迟秒数
/// @param task 回调
+ (xAsyncTask*)asyncTaskWithQueue:(dispatch_queue_t)queue after:(double)seconds task:(void(^)(void))task;

/// 创建一个延迟任务
/// @param seconds 延迟秒数
+ (xDelayTask*)delayTaskWithDelay:(double)seconds;

/// 创建一个自定义任务
/// @param handler 执行回调
+ (xCustomTask*)customTaskWithHandler:(void(^)(xTaskHandle*))handler;

/// 创建一个ALL组合任务，会立刻执行，注意保存返回的xCompositeTask，否则可能还未执行完就连同子task一起被回收了
/// @param tasks 任务数组
/// @param callback 完成回调
+ (xCompositeTask*)all:(NSArray<id<xTaskProtocol>>*)tasks callback:(void(^)(NSArray<id<xTaskProtocol>>*))callback;

/// 创建一个ANY组合任务，会立刻执行，注意保存返回的xCompositeTask，否则可能还未执行完就连同子task一起被回收了
/// @param tasks 任务数组
/// @param callback 完成回调
+ (xCompositeTask*)any:(NSArray<id<xTaskProtocol>>*)tasks callback:(void(^)(NSArray<id<xTaskProtocol>>*))callback;
@end

NS_ASSUME_NONNULL_END
