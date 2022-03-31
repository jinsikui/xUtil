

#import <XCTest/XCTest.h>
#import "xPersistantQueue.h"
#import "xUtil.h"

@interface xPersistantQueueTests : XCTestCase
@property(nonatomic,strong) xPersistantQueue *queue;
@end

@implementation xPersistantQueueTests

- (void)setUp {
    _queue = [xPersistantQueue queueWithName:@"test.sqlite"];
}

- (void)tearDown {
    
}

- (void)testInqueue {
    [_queue deleteAll];
    __block NSInteger count = 0;
    _queue.processCallback = ^(NSObject * _Nonnull data, xPersistantQueue * _Nonnull queue) {
        NSLog(@">>>>> data: %@", data);
        count ++;
        [queue completeProcessData:data];
    };
    [_queue inqueueData:@{@"name":@"JSK"}];
    [_queue inqueueData:@{@"name":@"YXP"}];
    [_queue inqueueData:@{@"name":@"JXX"}];
    [NSThread sleepForTimeInterval:3];
    XCTAssert(count == 3);
}

- (void)testProcessAsync {
    [_queue deleteAll];
    __block NSInteger count = 0;
    _queue.processCallback = ^(NSObject * _Nonnull data, xPersistantQueue * _Nonnull queue) {
        NSLog(@">>>>> data: %@", data);
        count ++;
        [xTask asyncGlobalAfter:1 task:^{
            [queue completeProcessData:data];
        }];
    };
    [_queue inqueueData:@{@"name":@"JSK"}];
    [_queue inqueueData:@{@"name":@"YXP"}];
    [_queue inqueueData:@{@"name":@"JXX"}];
    [NSThread sleepForTimeInterval:5];
    XCTAssert(count == 3);
}


/// 按顺序调testRestart0，testRestart1，测试处理失败重启
- (void)testRestart0 {
    [_queue deleteAll];
    [_queue inqueueData:@{@"count":@(1)}];
    [_queue inqueueData:@{@"count":@(2)}];
    [_queue inqueueData:@{@"count":@(3)}];
    _queue.processCallback = ^(NSObject * _Nonnull data, xPersistantQueue * _Nonnull queue) {
        NSLog(@">>>>> data: %@", data);
        //不调complete，运行结束后再运行testRestart1
    };
    [NSThread sleepForTimeInterval:2];
}

- (void)testRestart1 {
    __block int count = 0;
    _queue.processCallback = ^(NSObject * _Nonnull data, xPersistantQueue * _Nonnull queue) {
        NSLog(@">>>>> data: %@", data);
        count ++;
        [queue completeProcessData:data];
    };
    [_queue inqueueData:@{@"count":@(4)}];
    [_queue inqueueData:@{@"count":@(5)}];
    [NSThread sleepForTimeInterval:5];
    XCTAssert(count == 5);
}

- (void)testInqueueInProcess {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [_queue deleteAll];
    _queue.processCallback = ^(NSObject * _Nonnull data, xPersistantQueue * _Nonnull queue) {
        NSLog(@">>>>> data: %@", data);
        NSNumber *number = ((NSDictionary*)data)[@"count"];
        int count = number.intValue;
        if(count < 10){
            [queue inqueueData:@{@"count":@(count + 1)}];
        }
        [queue completeProcessData:data];
        if(count == 10){
            [expect fulfill];
        }
    };
    [_queue inqueueData:@{@"count":@(1)}];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
}

- (void)testCompleteWithNil {
    [_queue deleteAll];
    __block int processCount = 0;
    __block int countValue = 0;
    _queue.processCallback = ^(NSObject * _Nonnull data, xPersistantQueue * _Nonnull queue) {
        NSLog(@">>>>> data: %@", data); // 1, 1, 1, 1, 1, 2, 3, 4, 5
        processCount ++;
        NSNumber *number = ((NSDictionary*)data)[@"count"];
        countValue = number.intValue;
        if(processCount < 5){
            /// 不会从队列删除数据，下次inqueue会再次触发process
            [queue completeProcessData:nil];
        }
        else{
            [queue completeProcessData:data];
        }
    };
    [_queue inqueueData:@{@"count":@(1)}];
    /// sleep 0.1是为了等待上一次process完成，否则在上一次process还没完成就inqueue下一个，虽然能inqueue成功，但不会再次触发process（process是串行处理）
    [NSThread sleepForTimeInterval:0.1];
    [_queue inqueueData:@{@"count":@(2)}];
    [NSThread sleepForTimeInterval:0.1];
    [_queue inqueueData:@{@"count":@(3)}];
    [NSThread sleepForTimeInterval:0.1];
    [_queue inqueueData:@{@"count":@(4)}];
    [NSThread sleepForTimeInterval:0.1];
    [_queue inqueueData:@{@"count":@(5)}];
    [NSThread sleepForTimeInterval:2];
    XCTAssert(processCount == 9);
    XCTAssert(countValue == 5);
}

@end
