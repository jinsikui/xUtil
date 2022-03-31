

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xDeviceTests : XCTestCase

@end

@implementation xDeviceTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
// 在模拟器 iPhone 8 系统14.1
- (void)testExample {
    
    XCTAssert([[xDevice deviceId] length] > 0);

    [xDevice setDeviceIdProvider:^NSString * _Nonnull {
        return @"34343";
    }];

    XCTAssert([[xDevice deviceId] isEqualToString:@"34343"]);

    XCTAssert([xDevice isPad] == false);

    XCTAssert([xDevice isPortraitOrientation] == true);
    
    XCTAssert([xDevice isiPhoneXSeries] == false);

    XCTAssert([xDevice screenWidth] == 375);

    XCTAssert([xDevice screenHeight] == 667);

    XCTAssert([xDevice statusBarHeight] == 20);

    XCTAssert([xDevice navBarHeight] == 44);

    XCTAssert([xDevice bottomBarHeight] == 0);

    XCTAssert([xDevice defaultTabBarHeight] == 49);

    NSString * iosVersion =  [NSString stringWithFormat:@"%f", [xDevice iosVersion]];
    XCTAssert( [iosVersion isEqualToString:@"14.100000"]);
    NSLog(@"%f", [xDevice iosVersion]);

    /// systemVersion
    XCTAssert([[xDevice iosRawVersion] isEqualToString:@"14.1"]);

    /// kCFBundleVersionKey
    XCTAssert([[xDevice buildVersion] isEqualToString:@"2.0.0.0"]);


    /// CFBundleShortVersionString
    XCTAssert([[xDevice appVersion] isEqualToString:@"2.0.0.0"]);

    XCTAssert([[xDevice appDisplayName] isEqualToString:@"xUtil"]);


    XCTAssert([[xDevice appDisplayName] isEqualToString:@"xUtil"]);

    XCTAssert([[xDevice deviceId] isEqualToString:@"34343"]);

    XCTAssert([[xDevice bundleId] isEqualToString:@"com.xutil.xUtil"]);
    

    XCTestExpectation *expect1 = [[XCTestExpectation alloc] initWithDescription:@""];
    [xDevice requestPermissionFor:xDevicePermissionTypeMicrophone callback:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        XCTAssert(isAuthorized == true && isFirstDetermined == false);
        [expect1 fulfill];

    }];
    XCTestExpectation *expect2 = [[XCTestExpectation alloc] initWithDescription:@""];

    [xDevice requestPermissionFor:xDevicePermissionTypeCamera callback:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        XCTAssert(isAuthorized == true && isFirstDetermined == false);
        [expect2 fulfill];

    }];
    XCTestExpectation *expect3 = [[XCTestExpectation alloc] initWithDescription:@""];

    [xDevice requestPermissionFor:xDevicePermissionTypePhotoLibrary callback:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        XCTAssert(isAuthorized == true && isFirstDetermined == false);
        [expect3 fulfill];

    }];
    XCTestExpectation *expect4 = [[XCTestExpectation alloc] initWithDescription:@""];

    [xDevice requestPermissionFor:xDevicePermissionTypeItunes callback:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        XCTAssert(isAuthorized == true && isFirstDetermined == false);
        [expect4 fulfill];

    }];
    
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [xDevice requestPermissionFor:xDevicePermissionTypePush callback:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        XCTAssert(isAuthorized == true && isFirstDetermined == false);
        [expect fulfill];

    }];

   
    /// 推送    ???? UIUserNotificationTypeNone 状态下 没回调
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:1];
    XCTAssert(result == XCTWaiterResultCompleted);
    /// 麦克风
    XCTWaiterResult result1 = [XCTWaiter waitForExpectations:@[expect1] timeout:1];
    XCTAssert(result1 == XCTWaiterResultCompleted);
    /// 相机
    XCTWaiterResult result2 = [XCTWaiter waitForExpectations:@[expect2] timeout:1];
    XCTAssert(result2 == XCTWaiterResultCompleted);

    /// 相册
    XCTWaiterResult result3 = [XCTWaiter waitForExpectations:@[expect3] timeout:1];
    XCTAssert(result3 == XCTWaiterResultCompleted);
    /// iTunes
    XCTWaiterResult result4 = [XCTWaiter waitForExpectations:@[expect4] timeout:1];
    XCTAssert(result4 == XCTWaiterResultCompleted);



}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
