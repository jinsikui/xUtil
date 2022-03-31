

#import <XCTest/XCTest.h>
#import "xUtil.h"
#import <AVFoundation/AVFoundation.h>

@interface xNoticeTest : XCTestCase

@end

@implementation xNoticeTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

//
- (void)testrAppFinishLaunching {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [[xNotice shared] registerAppFinishLaunching:self action:^(id param) {
        [expect fulfill];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationDidFinishLaunchingNotification object:nil];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
  
}

- (void)testAppWillEnterForeground {
     XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [[xNotice shared] registerAppWillEnterForeground:self action:^(id param) {
        [expect fulfill];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
   XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
  
}
- (void)testAppBecomeActive {
     XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [[xNotice shared] registerAppBecomeActive:self action:^(id param) {
        [expect fulfill];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
   XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
  
}
- (void)testAppWillResignActive {
   XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [[xNotice shared] registerAppWillResignActive:self action:^(id param) {
        [expect fulfill];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationWillResignActiveNotification object:nil];
   XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
  
}

- (void)testAppEnterBackground {
     XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [[xNotice shared] registerAppEnterBackground:self action:^(id param) {
        [expect fulfill];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
   XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
}
- (void)testAppWillTerminate {
     XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [[xNotice shared] registerAppWillTerminate:self action:^(id param) {
        [expect fulfill];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationWillTerminateNotification object:nil];
   XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
}

- (void)testAppAudioSessionRouteChange {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [[xNotice shared] registerAppAudioSessionRouteChange:self action:^(id param) {
        [expect fulfill];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:AVAudioSessionRouteChangeNotification object:nil];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
  
}
 //  自定义的notice
- (void)testSignOut {
    __block NSString * string = @"";
    [[xNotice shared] registerRequireSignOut:self action:^(id param) {
        string = (NSString *)param[kRequireSignOutToast];
    }];
    [[xNotice shared] postRequireSignOutWithToast:@"recevieNotice"];
    [NSThread sleepForTimeInterval:2];
    XCTAssert([string isEqualToString:@"recevieNotice"]);

  
}
- (void)testSignIn {
     XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
       [[xNotice shared] registerSignInWith:self action:^(id param) {
           [expect fulfill];
       }];
       [[xNotice shared] postSignIn];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:2];
    XCTAssert(result == XCTWaiterResultCompleted);
  
}

@end
