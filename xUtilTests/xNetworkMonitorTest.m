

#import <XCTest/XCTest.h>
#import "xNetworkMonitor.h"

@interface xNetworkMonitorTest : XCTestCase

@end

@implementation xNetworkMonitorTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testNetworkChange {
    [xNetworkMonitor.shared startMonitoring];
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [xNetworkMonitor.shared registerCallbackWithLife:self callback:^(AFNetworkReachabilityStatus status) {
        [expect fulfill];
    }];
   [ [NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingReachabilityDidChangeNotification object:nil userInfo:nil];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
}



@end
