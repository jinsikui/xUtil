

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xFontTests : XCTestCase

@end

@implementation xFontTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
   
    UIFont * font = [xFont lightPFWithSize:18];
    XCTAssert(font.pointSize == 18.00 && [font.fontName isEqualToString:@"PingFangSC-Light"]);

    UIFont * font1 = [xFont regularPFWithSize:18];
    XCTAssert(font1.pointSize == 18.00 && [font1.fontName isEqualToString:@"PingFangSC-Regular"]);


    UIFont * font2 = [xFont mediumPFWithSize:18];
    XCTAssert(font2.pointSize == 18.00 && [font2.fontName isEqualToString:@"PingFangSC-Medium"]);

    UIFont * font3 = [xFont semiboldPFWithSize:18];
    XCTAssert(font3.pointSize == 18.00 && [font3.fontName isEqualToString:@"PingFangSC-Semibold"]);

    
    UIFont * font4 = [xFont boldWithSize:18];
    XCTAssert(font4.pointSize == 18.00 && [font4.fontName isEqualToString:@".SFUI-Bold"]);

    /// 英文和数字字体
    UIFont * font5 = [xFont regularWithSize:18];
    XCTAssert(font5.pointSize == 18.00 && [font5.fontName isEqualToString:@".SFUI-Regular"]);

    /// 英文和数字字体
    UIFont * font6 = [xFont lightWithSize:18];
    XCTAssert(font6.pointSize == 18.00 && [font6.fontName isEqualToString:@".SFUI-Light"]);

}

-(BOOL)firstFont:(UIFont *)firstFont secondFont:(UIFont*)secondFont
{
    if ([firstFont.fontName isEqualToString:secondFont.fontName] && firstFont.pointSize == secondFont.pointSize)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
