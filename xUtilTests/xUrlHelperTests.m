

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xUrlHelperTests : XCTestCase

@end

@implementation xUrlHelperTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
  
    NSString * urlStr = @"https://lanhuapp.com/web/#/item/project/board?type=share_mark&pid=5e878ed3";
    NSString * normalUrl = @"https://lanhuapp.com/web/project/board?type=share_mark&pid=5e878ed3";
    
    NSString * urlEncodeStr = [xUrlHelper urlEncode:urlStr];
    

    NSString * urlDncodeStr = [xUrlHelper urlDecode:urlEncodeStr];

    XCTAssert([urlStr isEqualToString:urlDncodeStr]);


    NSString * mergeUrlStr = [xUrlHelper mergeToInput:@"https://lanhuapp.com/web/project/board?" queryParams:@{@"type" : @"share_mark", @"pid" : @"5e878ed3"}];
    XCTAssert([normalUrl isEqualToString:mergeUrlStr]);
    
    NSString * queryValueStr = [xUrlHelper queryValueIn:normalUrl name:@"pid"];
    XCTAssert([queryValueStr isEqualToString:@"5e878ed3"]);

    NSString * hostStr = [xUrlHelper hostFor:normalUrl];
    XCTAssert([hostStr isEqualToString:@"lanhuapp.com"]);

    NSString * pathStr = [xUrlHelper pathFor:normalUrl];
    XCTAssert([pathStr isEqualToString:@"/web/project/board"]);


    NSDictionary * paramsDict = [xUrlHelper paramsFor:normalUrl];
    NSDictionary * compareDict = @{@"type" : @"share_mark", @"pid": @"5e878ed3"};
    XCTAssert([paramsDict isEqualToDictionary:compareDict]);

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
