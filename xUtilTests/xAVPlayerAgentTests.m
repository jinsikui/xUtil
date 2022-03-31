

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xAVPlayerAgentTests : XCTestCase
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) xAVPlayerAgent *agent;
@end

@implementation xAVPlayerAgentTests

- (void)setUp {
    self.url = [NSURL fileURLWithPath:[xFile bundlePath:@"/bye.mp3"] isDirectory:YES];
    self.agent = [xAVPlayerAgent shared];
}

- (void)testPlayerState {
    XCTAssert(self.agent.state == xAVPlayerStateNone);
    [self.agent play:self.url];
    XCTAssert(self.agent.state == xAVPlayerStateLoading);
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.agent.state == xAVPlayerStatePlaying) {
            [expect fulfill];
        }
    });
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
    [self.agent pause];
    XCTAssert(self.agent.state == xAVPlayerStatePaused);
    [self.agent play:self.url];
    XCTAssert(self.agent.state == xAVPlayerStatePlaying);
    [self.agent stop];
    XCTAssert(self.agent.state == xAVPlayerStateNone);
    [self.agent play:self.url];
    XCTAssert(self.agent.state == xAVPlayerStateLoading);
}

- (void)testPlayerTime {
    XCTAssert(self.agent.curTime == 0);
    XCTAssert(round(self.agent.duration) == 0);
    [self.agent play:self.url];
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    XCTestExpectation *expect1 = [[XCTestExpectation alloc] initWithDescription:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(self.agent.curTime > 0);
        XCTAssert(round(self.agent.duration) == 257);
        [expect fulfill];
        [self.agent seek:100];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssert(self.agent.curTime >= 100);
            [expect1 fulfill];
        });
    });
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect, expect1] timeout:20];
    XCTAssert(result == XCTWaiterResultCompleted);
}

@end
