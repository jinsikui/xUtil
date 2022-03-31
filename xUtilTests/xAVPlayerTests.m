

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xAVPlayerTests : XCTestCase <xAVPlayerDelegate>
@property (nonatomic, strong) xAVPlayer *player;
@end

@implementation xAVPlayerTests

- (void)setUp {
    NSURL *url = [NSURL fileURLWithPath:[xFile bundlePath:@"/bye.mp3"] isDirectory:YES];
    self.player = [[xAVPlayer alloc] initWithUrl:url];
    self.player.delegate = self;
    XCTAssert([self.player.url.absoluteString isEqualToString:url.absoluteString]);
}

- (void)testPlayerState {
    XCTAssert(self.player.state == xAVPlayerStateNone);
    // 没调用prepare时直接play没作用
    [self.player play];
    XCTAssert(self.player.state == xAVPlayerStateNone);
    // 正常播放
    [self.player prepareForPlay];
    [self.player play];
    XCTAssert(self.player.state == xAVPlayerStateLoading);
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.player.state == xAVPlayerStatePlaying) {
            [expect fulfill];
        }
    });
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
    [self.player pause];
    XCTAssert(self.player.state == xAVPlayerStatePaused);
    [self.player play];
    XCTAssert(self.player.state == xAVPlayerStatePlaying);
    [self.player stop];
    XCTAssert(self.player.state == xAVPlayerStateNone);
}

- (void)testPlayerTime {
    XCTAssert(self.player.curTime == 0);
    XCTAssert(round(self.player.duration) == 0);
    [self.player play];
    XCTAssert(self.player.curTime == 0);
    XCTAssert(round(self.player.duration) == 0);
    [self.player seek:100];
    XCTAssert(self.player.curTime == 0);
    [self.player prepareForPlay];
    [self.player play];
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    XCTestExpectation *expect1 = [[XCTestExpectation alloc] initWithDescription:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(self.player.curTime > 0);
        XCTAssert(round(self.player.duration) == 257);
        [expect fulfill];
        [self.player seek:100];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            XCTAssert(self.player.curTime >= 100);
            [expect1 fulfill];
        });
    });
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect, expect1] timeout:20];
    XCTAssert(result == XCTWaiterResultCompleted);
}

#pragma mark - xAVPlayerDelegate
- (void)xAVPlayerOnStateChanged:(xAVPlayerState)state curTime:(NSTimeInterval)curTime duration:(NSTimeInterval)duration {
    XCTAssert(state == self.player.state);
    XCTAssert(curTime <= self.player.curTime);
    XCTAssert(duration == self.player.duration);
}

@end
