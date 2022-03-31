

#import <XCTest/XCTest.h>
#import "xLocationManager.h"
#import <UIKit/UIKit.h>
@interface xLocationManagerTest : XCTestCase

@end

@implementation xLocationManagerTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testRequestLocationAuthorization {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [xLocationManager.shared requestLocationAuthorization:^(BOOL isAuthorized, BOOL isFirstDetermined) {
        [expect fulfill];
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
}



@end
