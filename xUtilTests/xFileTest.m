

#import <XCTest/XCTest.h>

#import "xFile.h"

#if TARGET_IPHONE_SIMULATOR
static NSString * const kxFileTestFirstDirName = @"/Users/";
#else
static NSString * const kxFileTestFirstDirName = @"/private/";
#endif

@interface xFileTest : XCTestCase

@end

@implementation xFileTest

- (void)setUp {

}

- (void)testDocumentPath {
    [self filePathVerifyWithPathFunction:@selector(documentPath:) dirName:@"Documents"];
}

- (void)testTmpPath {
    [self filePathVerifyWithPathFunction:@selector(tmpPath:) dirName:@"tmp"];
}

- (void)testCachesPath {
    [self filePathVerifyWithPathFunction:@selector(cachePath:) dirName:@"Caches"];
}

- (void)testAppSupportPath {
    [self filePathVerifyWithPathFunction:@selector(appSupportPath:) dirName:@"Application Support"];
}

- (void)testMainBundlePath {
    NSString *infoPlist = @"Info.plist";
    NSString *mainBundlePath = [xFile bundlePath:infoPlist];
    
    //  验证路径正确性
    XCTAssertTrue([mainBundlePath hasPrefix:kxFileTestFirstDirName]);
    //  验证文件名正确性
    XCTAssertTrue([mainBundlePath.lastPathComponent isEqualToString:infoPlist]);
    
    //  验证文件夹正确性
    NSArray<NSString *> *paths = [mainBundlePath pathComponents];
    NSString *pathDirName = paths[paths.count - 2];
    NSString *projectDir = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleExecutableKey];
    projectDir = [projectDir stringByAppendingPathExtension:@"app"];
    XCTAssertTrue([pathDirName isEqualToString:projectDir]);
}

- (void)testFileExistsAtPath {
    //  Bundle下文件夹
    NSString *infoPlist = @"Info.plist";
    NSString *mainBundlePath = [xFile bundlePath:infoPlist];
    XCTAssertTrue([xFile fileExistsAtPath:mainBundlePath]);
    
    //  Document文件夹下
    NSString *documentFilePath = [xFile documentPath:@"testFileExistsAtPath.txt"];
    [xFile createFileIfNotExistsAtPath:documentFilePath];
    //  这时候文件应该存在
    XCTAssertTrue([xFile fileExistsAtPath:documentFilePath]);
    [xFile deleteFileOfPath:documentFilePath];
    //  现在应不存在了
    XCTAssertFalse([xFile fileExistsAtPath:documentFilePath]);
}

- (void)testFolderExistsAtPath {
    NSString *bundlePath = [NSBundle mainBundle].bundlePath;
    NSString *documentPath = [xFile documentPath:@""];
    //  Bundle
    XCTAssertTrue([xFile folderExistsAtPath:bundlePath]);
    XCTAssertFalse([xFile folderExistsAtPath:[bundlePath stringByAppendingPathComponent:@"我不存在"]]);
    //  Document
    XCTAssertTrue([xFile folderExistsAtPath:documentPath]);
    XCTAssertFalse([xFile folderExistsAtPath:[documentPath stringByAppendingPathComponent:@"我不存在"]]);
}

- (void)testHasDocumentFile {
    NSString *testFilePath = [xFile documentPath:@"testHasDocumentFile.txt"];
    [self hasFileVerifyWithFunction:@selector(hasDocumentFile:) filePath:testFilePath];
}

- (void)testHasCacheFile {
    NSString *testFilePath = [xFile cachePath:@"testHasDocumentFile.txt"];
    [self hasFileVerifyWithFunction:@selector(hasCacheFile:) filePath:testFilePath];
}

- (void)testHasAppSupportFile {
    NSString *testFilePath = [xFile appSupportPath:@"testHasDocumentFile.txt"];
    [self hasFileVerifyWithFunction:@selector(hasAppSupportFile:) filePath:testFilePath];
}

- (void)testGetDataFromFileOfPath {
    NSString *testFilePath = [xFile documentPath:@"testHasDocumentFile.txt"];
    //  data应不存在
    XCTAssertTrue([xFile getDataFromFileOfPath:testFilePath].length == 0);
    NSString *dataStr = @"我是验证内容";
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    //  写入
    XCTAssertTrue([xFile saveData:data toPath:testFilePath]);
    //  读取
    data = [xFile getDataFromFileOfPath:testFilePath];
    //  验证
    NSString *fileStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileStr isEqualToString:dataStr]);
    //  删掉
    XCTAssertTrue([xFile deleteFileOfPath:testFilePath]);
    XCTAssertTrue([xFile getDataFromFileOfPath:testFilePath].length == 0);
}

- (void)testGetDataFromFileUrl {
    //  请求百度
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com/"];
    NSData *data = [xFile getDataFromFileUrl:url];
    XCTAssert(data.length > 0);
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([str containsString:@"百度一下"]);
    //  请求一个不存在的网址
    XCTAssertFalse([xFile getDataFromFileUrl:[NSURL URLWithString:@"http://abcd34215efg.hifsjk.lm123n.opq"]]);
}

///  所有json转换相关方法直接放一起测试了，总共经历四个转换过程，其中有一个出现问题都会导致不通过
- (void)testJsonFuns {
    //  支持的类型
    NSArray *testArrayObject = @[@"Json", @"测试", @"数组", @2, [NSNull null]];
    NSDictionary *testDict = @{
        @"字符串":@"字符串测试",
        @"数字":@3,
        @"空" : [NSNull null],
        @"数组":@[@"数", @"组", @"测", @"试", @4],
    };
    
    NSArray *allValidObjs = @[
        testArrayObject,
        testDict,
    ];
    
    //  测试合法类型是否成功
    [allValidObjs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //  转data和string
        NSData *jsonData = [xFile objectToJsonData:obj];
        NSString *jsonStr = [xFile objectToJsonStr:obj];
        XCTAssert(jsonData.length);
        XCTAssert(jsonStr.length);
        //  转回来
        id objFromData = [xFile jsonDataToObject:jsonData];
        id objFromStr = [xFile jsonStrToObject:jsonStr];
        XCTAssertTrue([self objectCompareWithObj1:obj obj2:objFromData]);
        XCTAssertTrue([self objectCompareWithObj1:obj obj2:objFromStr]);
    }];
    
    //  不支持的类型
    NSObject *testInvalidObj = [NSObject new];
    NSObject *testInvalidObj2 = @{@"invalid":[NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:@{@"user":@"info"}]};
    //  测试非法类型是否失败
    XCTAssert([xFile objectToJsonData:testInvalidObj].length == 0);
    XCTAssert([xFile objectToJsonStr:testInvalidObj].length == 0);
    XCTAssert([xFile objectToJsonData:testInvalidObj2].length == 0);
    XCTAssert([xFile objectToJsonStr:testInvalidObj2].length == 0);
}

- (void)testBase64Funcs {
    // @"我是测试内容"
    NSString *base64Str = @"5oiR5piv5rWL6K+V5YaF5a65";
    NSString *invalidBase64Str = @"safkjhoiqunck+=";
    
    //  base64 string -> base64 data
    NSData *dataFromB64Str = [xFile base64ToData:base64Str];
    XCTAssert(dataFromB64Str.length);
    XCTAssertFalse([xFile base64ToData:invalidBase64Str].length);
    
    //  base64 data -> base64 string
    NSString *strFromB64Data = [xFile dataToBase64:dataFromB64Str];
    XCTAssert([strFromB64Data isEqualToString:base64Str]);
}

- (void)testMD5Funcs {
    //  字符串转MD5
    NSString *testStr = @"我是测试内容";
    NSString *correctMD5 = @"5E2941AFB631694A413B0E9536669345";
    XCTAssert([correctMD5 isEqualToString:[xFile strToMD5:testStr]]);
    
    //  Data转MD5
    NSData *testData = [testStr dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssert([correctMD5 isEqualToString:[xFile dataToMD5:testData]]);
}

/**
 getDicFromFileOfPath:
 saveDic:toPath:
 */
- (void)testDictArchiveAndUnArchive {
    NSString *savePath = [xFile cachePath:@"testDictArchiveAndUnArchive.txt"];
    NSString *savePath_empty = [xFile cachePath:@"testDictArchiveAndUnArchive.empty"];
    NSString *savePath_false = [xFile cachePath:@"testDictArchiveAndUnArchive.false"];
    NSDictionary *validDict = @{
        @"测试":@"内容",
        @"数字":@2,
        @"数组":@[@"字符串", @3, [NSNull null]],
    };
    
    NSMutableDictionary *validReplaceDict = [validDict mutableCopy];
    validReplaceDict[@4] = @"后加的";
    //  不合规的内容
    NSDictionary *invalidDict = @{
        @"invalid" : [NSObject new],
    };
    [xFile deleteFileOfPath:savePath];
    //  应该取不到
    XCTAssertFalse([xFile getDicFromFileOfPath:savePath].allKeys.count);
    //  存
    XCTAssert([xFile saveDic:validDict toPath:savePath]);
    //  存不合规的内容
    XCTAssertFalse([xFile saveDic:invalidDict toPath:savePath_false]);

    //  取
    NSDictionary *dictFromDrive = [xFile getDicFromFileOfPath:savePath];
    XCTAssert([self objectCompareWithObj1:validDict obj2:dictFromDrive]);
    //  取空
    XCTAssertNil([xFile getDicFromFileOfPath:savePath_empty]);
    //  取不合规的
    XCTAssertFalse([xFile getDicFromFileOfPath:savePath_false].allKeys.count);
    
    //  覆盖
    XCTAssert([xFile saveDic:validReplaceDict toPath:savePath]);
    //  再取
    NSDictionary *dictReplaceFromDrive = [xFile getDicFromFileOfPath:savePath];
    XCTAssert([self objectCompareWithObj1:validReplaceDict obj2:dictReplaceFromDrive]);
    
    //  删掉测试文件
    XCTAssert([xFile deleteFileOfPath:savePath]);
    XCTAssert([xFile deleteFileOfPath:savePath_empty]);
}

- (void)testCreateFileIfNotExistsAtPath {
    NSString *savePath = [xFile tmpPath:@"missing_dir/testCreateFileIfNotExistsAtPath.txt"];
    NSString *saveDir = [xFile tmpPath:@"missing_dir"];
    NSString *invalidSavePath = @"http://www.baidu.com/invalid.txt";
    NSString *invalidSavePath2 = @"";
    //  确保文件不存在
    [xFile deleteFileOfPath:savePath];
    [xFile deleteFolder:saveDir];
    //  写入磁盘
    [xFile createFileIfNotExistsAtPath:savePath];
    XCTAssert([xFile folderExistsAtPath:saveDir]);
    XCTAssert([xFile fileExistsAtPath:savePath]);
    //  文件已经存在测试
    [xFile createFileIfNotExistsAtPath:savePath];
    XCTAssert([xFile folderExistsAtPath:saveDir]);
    XCTAssert([xFile fileExistsAtPath:savePath]);
    //  测试写入失败
    [xFile createFileIfNotExistsAtPath:invalidSavePath];
    [xFile createFileIfNotExistsAtPath:invalidSavePath2];
    //  清除测试文件
    [xFile deleteFileOfPath:savePath];
    [xFile deleteFolder:saveDir];
}

- (void)testAppendTextToFile {
    NSString *savePath = [xFile tmpPath:@"testAppendTextToFile.txt"];
    NSString *testStr1 = @"测试内容1";
    NSString *testStr2 = @"测试内容2😈😃";

    //  先确保无此文件
    [xFile deleteFileOfPath:savePath];
    //  第一次写入
    [xFile appendText:testStr1 toFile:savePath];
    NSData *fileData1 = [xFile getDataFromFileOfPath:savePath];
    NSString *fileStr1 = [[NSString alloc] initWithData:fileData1 encoding:NSUTF8StringEncoding];
    XCTAssert([xFile fileExistsAtPath:savePath]);
    XCTAssert([fileStr1 isEqualToString:testStr1]);
    //  第二次写入
    [xFile appendText:testStr2 toFile:savePath];
    NSData *fileData2 = [xFile getDataFromFileOfPath:savePath];
    NSString *fileStr2 = [[NSString alloc] initWithData:fileData2 encoding:NSUTF8StringEncoding];
    XCTAssert([fileStr2 isEqualToString:[testStr1 stringByAppendingString:testStr2]]);
    
    //  多线程写入
    //  不需要保证顺序正确，但是至少字符串长度应该是正确的
    NSInteger count = 100;
    NSMutableArray<XCTestExpectation *> *exps = [NSMutableArray arrayWithCapacity:count];
    for (int i=0; i<count; i++) {
        XCTestExpectation *mexp = [self expectationWithDescription:[NSString stringWithFormat:@"writeFile%d", i]];
        [exps addObject:mexp];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [xFile appendText:testStr2 toFile:savePath];
            [mexp fulfill];
        });
    }
    
    //  验证长度
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        NSData *fileData3 = [xFile getDataFromFileOfPath:savePath];
        NSString *fileStr3 = [[NSString alloc] initWithData:fileData3 encoding:NSUTF8StringEncoding];
        NSInteger fufillLen = (fileStr2.length + testStr2.length * count);
        XCTAssert(fileStr3.length == fufillLen);
        //  清空测试文件
        [xFile deleteFileOfPath:savePath];
    }];
}

- (void)testSaveDataToPath {
    NSString *savePath = [xFile tmpPath:@"testSaveDataToPath.txt"];
    NSString *savePath2 = [xFile tmpPath:@"testSaveDataToPath/testSaveDataToPath.txt"];
    NSString *inValidSavePath = @"http://www.baidu.com";
    NSString *testStr1 = @"测试内容1🐻";
    NSData *testData1 = [testStr1 dataUsingEncoding:NSUTF8StringEncoding];
    
    //  确保无此文件
    [xFile deleteFileOfPath:savePath];
    [xFile deleteFolder:[xFile tmpPath:@"testSaveDataToPath"]];
    
    BOOL replace = NO;
TestSaveDataToPathWriteAndRead:
    //  写入
    XCTAssert([xFile saveData:testData1 toPath:savePath]);
    //  读取
    NSString *fileStr = [[NSString alloc] initWithContentsOfFile:savePath encoding:NSUTF8StringEncoding error:nil];
    XCTAssert([fileStr isEqualToString:testStr1]);
    //  覆盖
    if (!replace) {
        replace = YES;
        goto TestSaveDataToPathWriteAndRead;
    }
    
    //  写入一个不存在的文件夹的路径
    XCTAssert([xFile saveData:testData1 toPath:savePath2]);
    XCTAssert([xFile fileExistsAtPath:savePath2]);
    
    //  写入不合规的地址
    XCTAssertFalse([xFile saveData:testData1 toPath:inValidSavePath]);
    
    //  清除测试文件
    XCTAssert([xFile deleteFileOfPath:savePath]);
}

- (void)testDeleteFileOfPath {
    NSString *savePath = [xFile tmpPath:@"testDeleteFileOfPath.txt"];
    NSString *inValidSavePath = @"http://www.baidu.com";
    
    [xFile deleteFileOfPath:savePath];
    //  删除一个不存在的文件
    [xFile deleteFileOfPath:savePath];
    //  删除一个错误路径的文件
    [xFile deleteFileOfPath:inValidSavePath];
    
    //  创建一个新文件
    [xFile createFileIfNotExistsAtPath:savePath];
    XCTAssert([xFile fileExistsAtPath:savePath]);
    //  删除一个存在的文件
    [xFile deleteFileOfPath:savePath];
    XCTAssertFalse([xFile fileExistsAtPath:savePath]);
}

/**
 createFolder:
 deleteFolder:
 */
- (void)testCreateFolderAndDeleteFolder {
    NSString *validPath1 = [xFile tmpPath:@"testCreateFolderAndDeleteFolder"];
    NSString *validPath2 = [xFile tmpPath:@"testCreateFolderAndDeleteFolder.txt"];
    NSString *inValidPath = @"http://www.baidu.com";
    
    //  正常创建一个文件夹
    [xFile createFolder:validPath1];
    //  创建一个错误路径的文件夹, 应该什么都不会发生
    [xFile createFolder:inValidPath];
    //  创建一个txt文件，再创建一个同名的文件夹
    [xFile createFileIfNotExistsAtPath:validPath2];
    [xFile createFolder:validPath2];
    //  再创建一次应该也不会出错
    [xFile createFileIfNotExistsAtPath:validPath2];
    [xFile createFolder:validPath2];
    //  他们应该同时存在
    XCTAssert([xFile folderExistsAtPath:validPath1]);
    //  validPath2应该是一个文件，因为我们先创建的是文件不是文件夹
    XCTAssertFalse([xFile folderExistsAtPath:validPath2]);
    XCTAssert([xFile fileExistsAtPath:validPath2]);
    
    //  删除他们
    [xFile deleteFolder:validPath1];
    [xFile deleteFolder:validPath2];
    [xFile deleteFileOfPath:validPath2];
    [xFile deleteFolder:inValidPath];
    [xFile deleteFolder:@""];
    [xFile deleteFolder:nil];
    
    //  这时候应该不存在测试文件
    XCTAssertFalse([xFile folderExistsAtPath:validPath1]);
    XCTAssertFalse([xFile folderExistsAtPath:validPath2]);
    XCTAssertFalse([xFile fileExistsAtPath:validPath2]);
}

- (void)testFileSize {
    NSString *validPath = [xFile tmpPath:@"testFileSize.txt"];
    NSString *invalidPath1 = [xFile tmpPath:@"testFileSize.false"];
    NSString *invalidPath2 = @"https://www.baidu.com";
    
    //  确保无此文件
    [xFile deleteFileOfPath:validPath];
    
    NSString *str = @"我是测试内容😃🐱";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [xFile saveData:data toPath:validPath];
    [xFile saveData:data toPath:invalidPath2];
    
    XCTAssertEqual(data.length, [xFile fileSize:validPath]);
    XCTAssertFalse([xFile fileSize:invalidPath1]);
    XCTAssertFalse([xFile fileSize:invalidPath2]);
    
    [xFile deleteFileOfPath:validPath];
}

- (void)testFolderSizeAndRemoveFilesAtFolderPath {
    //  这是根文件夹
    NSString *dirPath1 = [xFile tmpPath:@"testFolderSize"];
    //  先清空
    [xFile deleteFolder:dirPath1];
    
    NSString *validPath1 = [xFile tmpPath:@"/testFolderSize/testFolderSize1.txt"];
    NSString *validPath2 = [xFile tmpPath:@"/testFolderSize/fold1/testFolderSize2.txt"];
    NSString *validPath3 = [xFile tmpPath:@"/testFolderSize/fold1/subfold1/testFolderSize3.txt"];
    NSString *validPath4 = [xFile tmpPath:@"/testFolderSize/fold1/subfold1/testFolderSize4.txt"];
    NSString *validPath5 = [xFile tmpPath:@"/testFolderSize/fold1/subfold2/testFolderSize5.txt"];
    NSString *validPath6 = [xFile tmpPath:@"/testFolderSize/fold2/testFolderSize6.txt"];
    
    NSString *invalidPath1 = [xFile tmpPath:@"testFolderSize.false"];
    NSString *invalidPath2 = @"https://www.baidu.com";
    NSString *str = @"我是测试内容😃🐱";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [xFile saveData:data toPath:validPath1];
    [xFile saveData:data toPath:validPath2];
    [xFile saveData:data toPath:validPath3];
    [xFile saveData:data toPath:validPath4];
    [xFile saveData:data toPath:validPath5];
    [xFile saveData:data toPath:validPath6];
    
    NSString *subDirPath1 = [xFile tmpPath:@"testFolderSize/fold1/subfold1"];
    NSString *subDirPath2 = [xFile tmpPath:@"testFolderSize/fold2"];
    //  这个文件夹下有6个文件
    XCTAssertEqual(data.length * 6, [xFile folderSize:dirPath1]);
    //  这个子文件夹下有2文件夹
    XCTAssertEqual(data.length * 2, [xFile folderSize:subDirPath1]);
    //  这个子文件夹下有1文件夹
    XCTAssertEqual(data.length * 1, [xFile folderSize:subDirPath2]);

    //  尝试获取一个文件的foldSize，应该为0
    XCTAssertFalse([xFile folderSize:validPath1]);
    //  尝试获取不存在的文件夹，应该为false
    XCTAssertFalse([xFile folderSize:invalidPath1]);
    XCTAssertFalse([xFile folderSize:invalidPath2]);
    
    //  全删了
    XCTAssert([xFile removeFilesAtFolderPath:dirPath1]);
    //  什么都没有了，应是0
    XCTAssertFalse([xFile folderSize:dirPath1]);
    //  尝试删一下百度
    [xFile removeFilesAtFolderPath:invalidPath2];
    //  尝试去清除一个不存在的文件夹
    XCTAssert([xFile removeFilesAtFolderPath:subDirPath1]);
#if !TARGET_IPHONE_SIMULATOR
    //  尝试去删除一个自己没有权限删除的文件夹（模拟器有权限）
    NSString *noPermiDir = [xFile tmpPath:@""];
    noPermiDir = noPermiDir.stringByDeletingLastPathComponent;
    noPermiDir = noPermiDir.stringByDeletingLastPathComponent;
    // noPermiDir = /private/var/mobile/Containers/Data/Application/
    //  没权限，读取不了，但是应该不会崩溃
    [xFile removeFilesAtFolderPath:noPermiDir];
#endif
    
    //  清除了
    [xFile deleteFolder:dirPath1];
}

- (void)testCopyFileFromPathToPath {
    NSString *path1 = [xFile tmpPath:@"testCopyFileFromPathToPath1.txt"];
    NSString *path2 = [xFile tmpPath:@"testCopyFileFromPathToPath2.txt"];
    NSString *path3 = [xFile tmpPath:@"testCopyFileFromPathToPath3.txt"];
    
    //  确保没有文件
    [xFile deleteFileOfPath:path1];
    [xFile deleteFileOfPath:path2];
    [xFile deleteFileOfPath:path3];
    
    XCTAssert([xFile saveData:[path1 dataUsingEncoding:NSUTF8StringEncoding] toPath:path1]);
    XCTAssert([xFile saveData:[path3 dataUsingEncoding:NSUTF8StringEncoding] toPath:path3]);
    XCTAssert([xFile copyFileFromPath:path1 toPath:path2]);
    NSString *path1Content = [[NSString alloc] initWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
    NSString *path2Content = [[NSString alloc] initWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    //  现在1和2相同
    XCTAssert([path1Content isEqualToString:path2Content]);
    //  尝试用Path3覆盖，应失败
    XCTAssertFalse([xFile copyFileFromPath:path3 toPath:path2]);
    path2Content = [[NSString alloc] initWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
    //  还是1和2相同
    XCTAssert([path2Content isEqualToString:path2Content]);
    
    [xFile deleteFileOfPath:path1];
    [xFile deleteFileOfPath:path2];
    [xFile deleteFileOfPath:path3];
}

#pragma mark - private func
///  根据对应方法，验证获取沙盒路径的合规性
- (void)filePathVerifyWithPathFunction:(SEL)pathFunc dirName:(NSString *)dirName {
    NSString *normalFileName = @"myfile.txt";
    NSString *normalPath = [xFile performSelector:pathFunc withObject:normalFileName];
    XCTAssertTrue([normalPath hasPrefix:kxFileTestFirstDirName]);
    XCTAssertTrue([[normalPath lastPathComponent] isEqualToString:normalFileName]);

    NSString *slashFileName = @"/myfile.txt";
    NSString *slashPath = [xFile performSelector:pathFunc withObject:slashFileName];
    XCTAssertTrue([normalPath isEqualToString:slashPath]);
    
    NSArray<NSString *> *paths = [normalPath pathComponents];
    NSString *pathDirName = paths[paths.count - 2];
    XCTAssertTrue([pathDirName isEqualToString:dirName]);
}

///  根据对应方法，验证判断沙盒文件是否存在的正确性
- (void)hasFileVerifyWithFunction:(SEL)func filePath:(NSString *)filePath {
    [xFile createFileIfNotExistsAtPath:filePath];
    //  刚创建完，存在
    XCTAssertTrue([xFile performSelector:func withObject:filePath.lastPathComponent]);
    [xFile deleteFileOfPath:filePath];
    //  删除了，不存在
    XCTAssertFalse([xFile performSelector:func withObject:filePath.lastPathComponent]);
}

- (BOOL)objectCompareWithObj1:(id)obj1 obj2:(id)obj2 {
    if ([obj1 isKindOfClass:[NSString class]]
        && [obj1 isKindOfClass:[NSString class]]) {
        return [obj1 isEqualToString:obj2];
    }
    
    else if ([obj1 isKindOfClass:[NSArray class]]
             && [obj2 isKindOfClass:[NSArray class]]) {
        __block BOOL equal = YES;
        NSArray *array2 = obj2;
        [(NSArray *)obj1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (array2.count <= idx) {
                equal = NO;
                *stop = YES;
            }
            
            id compareObj = array2[idx];
            
            if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                if (![self objectCompareWithObj1:obj obj2:compareObj]) {
                    equal = NO;
                    *stop = YES;
                }
            } else if (![obj isEqual:compareObj]) {
                equal = NO;
                *stop = YES;
            }
        }];
        
        return equal;
    }
    else if ([obj1 isKindOfClass:[NSDictionary class]]
             && [obj2 isKindOfClass:[NSDictionary class]]) {
        __block BOOL equal = YES;
        NSDictionary *dict2 = obj2;
        [(NSDictionary *)obj1 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (![dict2 objectForKey:key]) {
                equal = NO;
                *stop = YES;
            }
            
            id compareObj = dict2[key];
            
            if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDictionary class]]) {
                if (![self objectCompareWithObj1:obj obj2:compareObj]) {
                    equal = NO;
                    *stop = YES;
                }
            } else if (![obj isEqual:compareObj]) {
                equal = NO;
                *stop = YES;
            }
        }];
        
        return equal;
    }
    
    return [obj1 isEqual:obj2];
}

@end
