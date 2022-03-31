

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xAVAudioRecorderTests : XCTestCase
@property (nonatomic, strong) xAVAudioRecorder *recorder;
@end

@implementation xAVAudioRecorderTests

- (void)setUp {
    self.recorder = [[xAVAudioRecorder alloc] initWithFilePath:[xFile documentPath:@"testRecord.caf"]];
}

- (void)testState {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [xDevice requestPermissionFor:xDevicePermissionTypeMicrophone callback:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        [expect fulfill];
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:10];
    XCTAssert(result == XCTWaiterResultCompleted);
    
    XCTAssert(self.recorder.state == xAVAudioRecorderStateNone);
    [self.recorder record];
    XCTAssert(self.recorder.state == xAVAudioRecorderStateNone);
    [self.recorder prepareForRecord];
    [self.recorder record];
    XCTAssert(self.recorder.state == xAVAudioRecorderStateRecording);
    [self.recorder pause];
    XCTAssert(self.recorder.state == xAVAudioRecorderStatePaused);
    [self.recorder stop];
    XCTAssert(self.recorder.state == xAVAudioRecorderStatePaused);
}

- (void)testRecorderTime {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [xDevice requestPermissionFor:xDevicePermissionTypeMicrophone callback:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        [expect fulfill];
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:10];
    XCTAssert(result == XCTWaiterResultCompleted);
    
    XCTAssert(self.recorder.curTime == 0);
    [self.recorder record];
    XCTAssert(self.recorder.curTime == 0);
    [self.recorder prepareForRecord];
    [self.recorder record];
    XCTestExpectation *expect1 = [[XCTestExpectation alloc] initWithDescription:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(self.recorder.curTime > 0);
        [self.recorder stop];
        [expect1 fulfill];
    });
    XCTWaiterResult result1 = [XCTWaiter waitForExpectations:@[expect1] timeout:20];
    XCTAssert(result1 == XCTWaiterResultCompleted);
}

@end
