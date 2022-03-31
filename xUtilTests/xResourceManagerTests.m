

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xResourceManagerTests : XCTestCase
@property(nonatomic,strong) xResourceManager *rm;
@end

@implementation xResourceManagerTests

- (void)setUp {
    _rm = [xResourceManager resourceManagerForCategory:@"test"];
}

- (void)tearDown {
    [_rm clean];
}

- (void)testGetUrl {
    XCTestExpectation *expect = [[XCTestExpectation alloc] initWithDescription:@""];
    [_rm getUrl:@"http://xxxx.com/xxx.json"].then(^id(id ret){
        XCTAssert([xFile fileExistsAtPath:ret]);
        [expect fulfill];
        return nil;
    }).catch(^(NSError *error){
        XCTFail(@"%@", error);
    });
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expect] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
}

@end
