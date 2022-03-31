

#import <XCTest/XCTest.h>
#import "xTimer.h"
#import "xTask.h"

@interface xTimerTest : XCTestCase
@property (nonatomic ) NSDate * nowDate;

@end

@implementation xTimerTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMainTimer {
     XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    xTimer * globalTimer =  [xTimer timerOnMainWithIntervalSeconds:1 fireOnStart:YES action:^{
        if (NSThread.isMainThread) {
            [expect fulfill];
        }
    }];
    [globalTimer start];
   XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:10];
    XCTAssert(result == XCTWaiterResultCompleted);
}
- (void)testGlobalTimer {
    NSDate * date = [NSDate date];
    __block NSTimeInterval interval = 0;
    xTimer * globalTimer =  [xTimer timerOnGlobalWithIntervalSeconds:1 fireOnStart:NO action:^{
        NSDate * now = [NSDate date];
        interval = [now timeIntervalSinceDate:date];
        //因为有start运行在date之后的原因导致的一些误差 所以时间大概在 1.0001到1.002 这个范围内
        NSLog(@"<<<< interval %f",interval);
        dispatch_queue_t queue = dispatch_get_current_queue();
        XCTAssert( queue == dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) );
    }];
    [globalTimer start];
    [NSThread sleepForTimeInterval:1.1];
    XCTAssert(interval<1.005);
}

- (void)testGlobalTimerWithFireOnStart {
    NSDate * date = [NSDate date];
    __block NSTimeInterval interval = 0;
    xTimer * globalTimer =  [xTimer timerOnGlobalWithIntervalSeconds:1 fireOnStart:YES action:^{
        NSDate * now = [NSDate date];
        interval = [now timeIntervalSinceDate:date];
        NSLog(@"<<<< interval %f",interval);
    }];
     [globalTimer start];
    [NSThread sleepForTimeInterval:0.2];
    XCTAssert(interval<0.005);
    
}

- (void)testGlobalTimerStop {
     __block NSInteger count = 0;
    xTimer * globalTimer =  [xTimer timerOnGlobalWithIntervalSeconds:1 fireOnStart:YES action:^{
        count += 1;
    }];
    [globalTimer start];
    [xTask asyncGlobalAfter:0.9 task:^{
        [globalTimer stop];
    }];
    [NSThread sleepForTimeInterval:2];
    XCTAssert(count == 1);
}

//测试xtimmer切换前后台的情况
- (void)testGlobalTimerWithExplicitSuspendWhenResignActive  {
     __block NSInteger count = 0;
    xTimer * globalTimer =  [xTimer timerOnGlobalWithIntervalSeconds:1 fireOnStart:NO action:^{
        count += 1;
        NSLog(@"<<<< %ld",(long)count);
    }];
    [globalTimer setExplicitSuspendWhenResignActive];
    [globalTimer start];
    //按照这个模拟，其实在后台的时间应该是5.9秒 然后其实正常是10秒count为10 但是因为在系统发出UIApplicationDidBecomeActiveNotification这个通知后 xtimer会立即fire一次，所以会有timer在同一秒中fire两次 然后又因为有运行时间误差的原因，所以count最后会是4或者5
    [xTask asyncGlobalAfter:1.1 task:^{
        NSLog(@"<<<< %ld",(long)count);
         [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationWillResignActiveNotification object:nil];
    }];

    [xTask asyncGlobalAfter:7 task:^{
        NSLog(@"<<<< %ld",(long)count);
            [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
       }];
    [NSThread sleepForTimeInterval:10];
    XCTAssert(count<=5);
//    下面的例子timer 就在47秒这一秒中fire了两次
//    2020-12-25 17:20:40.464821+0800 xUtil[15673:259571] <<<< 1
//    2020-12-25 17:20:40.669242+0800 xUtil[15673:259571] <<<< 1
//    2020-12-25 17:20:47.159423+0800 xUtil[15673:259574] <<<< 1
//    2020-12-25 17:20:47.159686+0800 xUtil[15673:259645] <<<< 2
//    2020-12-25 17:20:47.465304+0800 xUtil[15673:259574] <<<< 3
//    2020-12-25 17:20:48.465379+0800 xUtil[15673:259574] <<<< 4
//    2020-12-25 17:20:49.464192+0800 xUtil[15673:259645] <<<< 5
}


@end
