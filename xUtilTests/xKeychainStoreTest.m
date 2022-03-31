

#import <XCTest/XCTest.h>
#import "xXCTUserDefineNSCodingObj.h"
#import "xKeychainStore.h"

static NSString * const xKeychainStoreTestKey = @"xKeychainStoreTestKey";
static NSString * const xKeychainStoreEmptyTestKey = @"xKeychainStoreEmptyTestKey";
static int const xKeychainPerformaceTestCount = 100;


@interface xKeychainStoreTest : XCTestCase

@end

@implementation xKeychainStoreTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

#pragma mark - unit test func
- (void)testDefaultStore {
    xKeychainStore *store = [xKeychainStore defaultStore];
    XCTAssertTrue([store isKindOfClass:[xKeychainStore class]]);
}

- (void)testStoreKeyValue {
    //  测试存各种类型的值
    xKeychainStore *store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    
    //  存
    NSArray *testObjs = @[
        @"nsstr",
        [NSNull null],
        @998,
        @{@"k1":@"v1", @"k2":@"v2", @"k3":@"v3"},
        @[@"a", @"b", @"c"],
        [[xXCTUserDefineNSCodingObj alloc] initWithMyProp:@"xXCTUserDefineCopyObj"],
    ];
    
    NSMutableDictionary *testObjMap = [NSMutableDictionary dictionaryWithCapacity:testObjs.count];
    [testObjs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"testKey:%@",[obj description]];
        testObjMap[key] = obj;
    }];
    
    [testObjMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [store setObject:obj forKeyedSubscript:key];
    }];
    

    //  取
    store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    xKeychainStore *emptyStore = [xKeychainStore storeWithName:xKeychainStoreEmptyTestKey];

    __block NSInteger hitCount = 0;
    //  emptyHitCount是从一个从来没存过东西的store里取东西，最后这个值应该是0，也就是取不到任何东西
    __block NSInteger emptyHitCount = 0;
    
    [testObjMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL hit = [[store objectForKeyedSubscript:key] isEqual:obj];
        BOOL emptyHit = [[emptyStore objectForKeyedSubscript:key] isEqual:obj];
        hitCount += hit ? 1 : 0;
        emptyHitCount += emptyHit ? 1 : 0;
    }];
    
    XCTAssertTrue(hitCount == testObjMap.allKeys.count);
    XCTAssertTrue(emptyHitCount == 0);
    
    //  放一个不合规的object再存一次试试,应该失败，但是不报错
    [store setObject:@"invalid_key" forKeyedSubscript:@{@"v":@[[NSObject new]]}];
    
    //  清空
    [testObjMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [store setObject:nil forKeyedSubscript:key];
    }];
}

- (void)testStoreNilValue {
    //  value 是 nil
    xKeychainStore *store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    NSString *strnil = nil;
    [store setObject:strnil forKeyedSubscript:@"objnil"];
    XCTAssertNil([store objectForKeyedSubscript:@"objnil"]);
}

- (void)testStoreKeyValueNotValid {
    //  key不合规
    xKeychainStore *store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    NSString *keyInvalid = (NSString *)[NSObject new];
    NSString *valueValid = @"I'm value";
    [store setObject:valueValid forKeyedSubscript:keyInvalid];
    XCTAssertNil([store objectForKeyedSubscript:keyInvalid]);
    
    //  value不合规
    NSString *keyValid = @"validKey";
    NSString *valueInvalid = (NSString *)[NSObject new];
    [store setObject:valueInvalid forKeyedSubscript:keyValid];
    XCTAssertNil([store objectForKeyedSubscript:keyValid]);
}

- (void)testRemoveAndReplaceObject {
    xKeychainStore *store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    NSString *storeKey = @"testRemoveAndReplaceObject";
    NSString *objOrigin = @"ImObjectOrigin";
    NSString *objReplace = @"ImObjectReplace";
    //  存
    [store setObject:objOrigin forKeyedSubscript:storeKey];
    XCTAssertTrue([objOrigin isEqualToString:[store objectForKeyedSubscript:storeKey]]);
    //  覆盖
    [store setObject:objReplace forKeyedSubscript:storeKey];
    XCTAssertTrue([objReplace isEqualToString:[store objectForKeyedSubscript:storeKey]]);
    //  清空
    [store setObject:nil forKeyedSubscript:storeKey];
    XCTAssertNil([store objectForKeyedSubscript:storeKey]);
}

- (void)testStorePerformace {
    xKeychainStore *store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    [self measureBlock:^{
        for (int i=0; i<xKeychainPerformaceTestCount; i++) {
            NSString *obj = [@(i).stringValue stringByAppendingString:@"_testObj"];
            NSString *key = [@(i).stringValue stringByAppendingString:@"_testKey"];
            [store setObject:obj forKeyedSubscript:key];
        }
    }];
    
    for (int i=0; i<xKeychainPerformaceTestCount; i++) {
        NSString *key = [@(i).stringValue stringByAppendingString:@"_testKey"];
        XCTAssertNotNil([store objectForKeyedSubscript:key]);
    }
    
    //  clear
    [self testClearPerformaceTestObjects];
}

- (void)testLoadValuePerformace {
    xKeychainStore *store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    for (int i=0; i<xKeychainPerformaceTestCount; i++) {
        NSString *obj = [@(i).stringValue stringByAppendingString:@"_testObj"];
        NSString *key = [@(i).stringValue stringByAppendingString:@"_testKey"];
        [store setObject:obj forKeyedSubscript:key];
    }
    
    [self measureBlock:^{
        for (int i=0; i<xKeychainPerformaceTestCount; i++) {
            NSString *key = [@(i).stringValue stringByAppendingString:@"_testKey"];
            XCTAssertNotNil([store objectForKeyedSubscript:key]);
        }
    }];
    [self testClearPerformaceTestObjects];
}

- (void)testClearPerformaceTestObjects {
    xKeychainStore *store = [xKeychainStore storeWithName:xKeychainStoreTestKey];
    //  clear
    for (int i=0; i<xKeychainPerformaceTestCount; i++) {
        NSString *key = [@(i).stringValue stringByAppendingString:@"_testKey"];
        [store setObject:nil forKeyedSubscript:key];
        XCTAssertNil([store objectForKeyedSubscript:key]);
    }
}

@end
