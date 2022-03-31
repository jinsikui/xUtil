

#import <XCTest/XCTest.h>
#import "xUtil.h"

@interface xSocketServiceTests : XCTestCase<xSocketServiceDelegate>
@property(nonatomic,strong) xSocketService *service;
@property(nonatomic,strong) XCTestExpectation *openExpectation;
@property(nonatomic,strong) XCTestExpectation *dataExpectation;
@property(nonatomic,copy) NSString *data;
@end

@implementation xSocketServiceTests

- (void)setUp {
    _service = [[xSocketService alloc] initWithServers:@[@"wss://echo.websocket.org"] userInfo:nil];
}

- (void)tearDown {
    [_service close];
    _service = nil;
    _data = nil;
    
}

- (void)testOpen{
    _openExpectation = [[XCTestExpectation alloc] initWithDescription:@""];
    _service.delegate = self;
    [_service open];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[_openExpectation] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
}

- (void)testGotData{
    _openExpectation = [[XCTestExpectation alloc] initWithDescription:@""];
    _dataExpectation = [[XCTestExpectation alloc] initWithDescription:@""];
    _service.delegate = self;
    [_service open];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[_openExpectation] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
    result = [XCTWaiter waitForExpectations:@[_dataExpectation] timeout:5];
    XCTAssert(result == XCTWaiterResultCompleted);
    XCTAssert([_data isEqualToString:@"{\"ver\":1,\"type\":0}"]);
}

/// 获取到数据的回调
/// @param data 可能是NSString也可能是NSData（使用protobuf时）
/// @param userInfo 创建时传入的数据
- (void)socketGotData:(id)data userInfo:(NSDictionary* __nullable)userInfo{
    NSLog(@"socket got data: %@", data);
    _data = (NSString*)data;
    [_dataExpectation fulfill];
}

/// 链接到服务器成功
/// @param userInfo 创建时传入的数据
- (void)socketConnectedWithUserInfo:(NSDictionary* __nullable)userInfo{
    [_openExpectation fulfill];
}

/// 关闭连接（会自动重试）
/// @param info "code":int,"reason":NSString*,"server":NSString*
- (void)socketClosedWithInfo:(NSDictionary*)info{
    NSLog(@"socket closed");
}

/// 发生错误
/// @param info "code":int,"reason":NSString*,"server":NSString*
- (void)socketErrorWithInfo:(NSDictionary*)info{
    NSLog(@"socket error");
}


@end
