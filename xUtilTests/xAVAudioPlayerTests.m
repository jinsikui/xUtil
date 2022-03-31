

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xAVAudioPlayerTests : XCTestCase <audioPlayerDelegate>
@property (nonatomic, strong) xAVAudioPlayer *player;
@end

@implementation xAVAudioPlayerTests

- (void)setUp {
    NSURL *url = [NSURL URLWithString:[xFile bundlePath:@"/bye.mp3"]];
    self.player = [[xAVAudioPlayer alloc] initWithUrl:url];
    self.player.delegate = self;
    XCTAssert([self.player.url.absoluteString isEqualToString:url.absoluteString]);
}

- (void)testPlayerState {
    XCTAssert(self.player.state == xAVAudioPlayerStateNone);
    // 没调用prepare时直接play没作用
    [self.player play];
    XCTAssert(self.player.state == xAVAudioPlayerStateNone);
    // 正常播放
    [self.player prepareForPlay];
    [self.player play];
    XCTAssert(self.player.state == xAVAudioPlayerStatePlaying);
    [self.player pause];
    XCTAssert(self.player.state == xAVAudioPlayerStatePaused);
    [self.player play];
    XCTAssert(self.player.state == xAVAudioPlayerStatePlaying);
    [self.player stop];
    XCTAssert(self.player.state == xAVAudioPlayerStateNone);
    [self.player play];
    XCTAssert(self.player.state == xAVAudioPlayerStatePlaying);
}

- (void)testPlayerTime {
    XCTAssert(self.player.curTime == 0);
    XCTAssert(round(self.player.duration) == 257);
    [self.player play];
    XCTAssert(self.player.curTime == 0);
    [self.player seek:100];
    XCTAssert(self.player.curTime == 100);
    [self.player prepareForPlay];
    [self.player play];
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(self.player.curTime >= 105);
        [expect fulfill];
    });
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:10];
    XCTAssert(result == XCTWaiterResultCompleted);
}

#pragma mark - audioPlayerDelegate
- (void)playerOnStateChanged:(xAVAudioPlayerState)state curTime:(NSTimeInterval)curTime duration:(NSTimeInterval)duration {
    XCTAssert(state == self.player.state);
    XCTAssert(curTime <= self.player.curTime);
    XCTAssert(duration == self.player.duration);
}

- (void)playerOnError:(NSError *)error {
    
}

@end
