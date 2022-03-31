

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xColorTests : XCTestCase

@end

@implementation xColorTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
   
    UIColor * rgbColor = [xColor fromRGB:0xEE64FF];

    UIColor * rgbColorA = [xColor fromRGBA:0xEE64FF alpha:0.8];

    UIColor * rgbStrColor = [xColor fromHexStr:@"#EE64FF"];

    XCTAssert([self firstColor:rgbColor secondColor:rgbStrColor] == true);

    UIColor * rgbStrColorA = [xColor fromHexStr:@"#EE64FF" alpha:0.8];

    XCTAssert([self firstColor:rgbColorA secondColor:rgbStrColorA] == true);
    XCTAssert([self firstColor:rgbColor secondColor:rgbStrColorA] == false);
    XCTAssert([self firstColor:rgbColorA secondColor:rgbStrColor] == false);


    UIColor * rgbaColor = [xColor fromRGBAHexStr:@"#EE64FF00"];

    UIColor * argbColor = [xColor fromARGBHexStr:@"#00EE64FF"];


    XCTAssert([self firstColor:rgbaColor secondColor:argbColor] == true);

    UIColor * rgb1Color = [xColor from8bitR:238 G:100 B:255];

    XCTAssert([self firstColor:rgbColor secondColor:rgb1Color] == true);

    UIColor * rgb1ColorA = [xColor from8bitR:238 G:100 B:255 alpha:0.8];
    XCTAssert([self firstColor:rgb1ColorA secondColor:rgbStrColorA] == true);
    XCTAssert([self firstColor:rgbColorA secondColor:rgb1ColorA] == true);

}


-(BOOL)firstColor:(UIColor*)firstColor secondColor:(UIColor*)secondColor
{
    if (CGColorEqualToColor(firstColor.CGColor, secondColor.CGColor))
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
