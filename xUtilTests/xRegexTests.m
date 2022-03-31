

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xRegexTests : XCTestCase

@end

@implementation xRegexTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    
    NSString *testStr = @"msdfdmmms56dfQs89dfmmmdddmmddfd";
    NSString *regexStr = @"ms";
    
    /// 用给定正则生成实例
    xRegex * regex = [[xRegex alloc] initWithPattern:regexStr];
    
    XCTAssert([regex test:testStr] == true);


    xRegex * emailRegex = [xRegex emailRegex];
    XCTAssert([emailRegex test:@"987654321@qq.com"] == true);
    XCTAssert([emailRegex test:@"987654321@@qq.com"] == false);
    XCTAssert([emailRegex test:@"987654321qq.com"] == false);
    XCTAssert([emailRegex test:@"987654321@163.com"] == true);

    XCTAssert([emailRegex test:@"987654321@163"] == true);
    XCTAssert([emailRegex test:@"987654321@163com"] == true);

    xRegex * phoneRegex = [xRegex phoneRegex];
    XCTAssert([phoneRegex test:@"18805318792"] == true);
    XCTAssert([phoneRegex test:@"1880531879"] == false);
    XCTAssert([phoneRegex test:@"018805318792"] == false);
    XCTAssert([phoneRegex test:@"1880531879a"] == false);

    /// 8-16位字母加数字    标点符号
    xRegex * passwordRegex = [xRegex passwordRegex];
    XCTAssert([passwordRegex test:@"fan18792"] == true);
    XCTAssert([passwordRegex test:@"fan_18792"] == true);
    XCTAssert([passwordRegex test:@"fan"] == false);
    XCTAssert([passwordRegex test:@"18792"] == false);
    XCTAssert([passwordRegex test:@"fan18792."] == true);

    xRegex * pureNumberRegex = [xRegex pureNumberRegex];
    XCTAssert([pureNumberRegex test:@"18805318792"] == true);
    XCTAssert([pureNumberRegex test:@"18805318792a"] == false);

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
