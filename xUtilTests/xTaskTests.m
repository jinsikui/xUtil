

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xTaskTests : XCTestCase

@property (nonatomic) xCompositeTask * compositeTask;
@property (nonatomic) xCompositeTask * compositeTask1;

@end

@implementation xTaskTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {

    [xTask executeMain:^{
        XCTAssert([NSThread currentThread] == [NSThread mainThread]);
    }];
    
    [xTask asyncMain:^{
        XCTAssert([NSThread currentThread] == [NSThread mainThread]);
    }];
    

    [xTask asyncGlobal:^{
        XCTAssert([NSThread currentThread] != [NSThread mainThread]);
    }];
    

    [xTask async:dispatch_get_main_queue() task:^{
        XCTAssert([NSThread currentThread] == [NSThread mainThread]);

    }];
    
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    CGFloat time1 = [self currentTime];
    [xTask asyncMainAfter:2 task:^{
        XCTAssert([NSThread currentThread] == [NSThread mainThread]);
        CGFloat time2 = [self currentTime];
        NSString * timeStr = [NSString stringWithFormat:@"%.0f", (time2 - time1)];
        XCTAssert([timeStr isEqualToString:@"2"]);
        [expect fulfill];

    }];

    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:3];
    XCTAssert(result == XCTWaiterResultCompleted);
    

    XCTestExpectation *expect1 = [[XCTestExpectation alloc] initWithDescription:@""];

    CGFloat time3 = [self currentTime];

    [xTask asyncGlobalAfter:2 task:^{
        XCTAssert([NSThread currentThread] != [NSThread mainThread]);
        CGFloat time4 = [self currentTime];
        NSString * timeStr = [NSString stringWithFormat:@"%.0f", (time4 - time3)];
        XCTAssert([timeStr isEqualToString:@"2"]);
        [expect1 fulfill];

    }];
    XCTWaiterResult result1 = [XCTWaiter waitForExpectations:@[expect1] timeout:3];
    XCTAssert(result1 == XCTWaiterResultCompleted);

   
    CGFloat time5 = [self currentTime];
    [xTask async:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) after:1 task:^{
        XCTAssert([NSThread currentThread] != [NSThread mainThread]);
        CGFloat time6 = [self currentTime];
        NSString * timeStr = [NSString stringWithFormat:@"%.0f", (time6 - time5)];
        XCTAssert([timeStr isEqualToString:@"1"]);
    }];

    xAsyncTask * task1 = [xTask asyncTaskWithQueue:dispatch_get_main_queue() task:^{
        XCTAssert([NSThread currentThread] == [NSThread mainThread]);

    }];

    
    CGFloat time7 = [self currentTime];

    xAsyncTask * task2 = [xTask asyncTaskWithQueue:dispatch_get_main_queue() after:1 task:^{
        XCTAssert([NSThread currentThread] != [NSThread mainThread]);
        CGFloat time8 = [self currentTime];
        NSString * timeStr = [NSString stringWithFormat:@"%.0f", (time8 - time7)];
        XCTAssert([timeStr isEqualToString:@"1"]);
    }];
    [task2 cancel];
 
    XCTestExpectation *expect5 = [[XCTestExpectation alloc] initWithDescription:@""];
    xCustomTask * custom = [xTask customTaskWithHandler:^(xTaskHandle * _Nonnull handle) {
        [expect5 fulfill];

    }];
    [custom execute];
    
    
    xDelayTask * delay =  [xTask delayTaskWithDelay:2];
    
    XCTWaiterResult result5 = [XCTWaiter waitForExpectations:@[expect5] timeout:2];
    XCTAssert(result5 == XCTWaiterResultCompleted);

    
    XCTestExpectation *expect3 = [[XCTestExpectation alloc] initWithDescription:@""];
    self.compositeTask =  [xTask all:@[delay, task1] callback:^(NSArray<id<xTaskProtocol>> * taskArray) {
        [expect3 fulfill];
    }];
    
    XCTWaiterResult result3 = [XCTWaiter waitForExpectations:@[expect3] timeout:4];
    XCTAssert(result3 == XCTWaiterResultCompleted);

    
    xAsyncTask * task4 = [xTask asyncTaskWithQueue:dispatch_get_main_queue() task:^{
        
    }];

    
    XCTestExpectation *expect4 = [[XCTestExpectation alloc] initWithDescription:@""];

    self.compositeTask1 = [xTask any:@[task4] callback:^(NSArray<id<xTaskProtocol>> * _Nonnull taskArray) {
        [expect4 fulfill];

    }];
    XCTWaiterResult result4 = [XCTWaiter waitForExpectations:@[expect4] timeout:6];
    XCTAssert(result4 == XCTWaiterResultCompleted);
    
   
}

- (CGFloat)currentTime {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    return time;
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
