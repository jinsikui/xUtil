

#import "xFile.h"
#import <CommonCrypto/CommonDigest.h>

@implementation xFile

+ (NSString *)documentPath:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:filename];
}

+ (NSString *)tmpPath:(NSString *)filename {
    NSString *tempPath = NSTemporaryDirectory();
    return [tempPath stringByAppendingPathComponent:filename];
}

+ (NSString *)bundlePath:(NSString *)filename {
    return [[NSBundle mainBundle] pathForResource:filename ofType:nil];
}

+ (NSString *)cachePath:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:filename];
}

+ (NSString *)appSupportPath:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:filename];
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    BOOL isD;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isD]) {
        if (isD) {
            return NO;
        }
        else{
            return YES;
        }
    }
    return NO;
}

+ (BOOL)folderExistsAtPath:(NSString *)path {
    BOOL isD;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isD]) {
        if (isD) {
            return YES;
        }
        else{
            return NO;
        }
    }
    return NO;
}

+ (BOOL)hasDocumentFile:(NSString*)filename{
    return [self fileExistsAtPath:[self documentPath:filename]];
}

+ (BOOL)hasCacheFile:(NSString*)filename{
    return [self fileExistsAtPath:[self cachePath:filename]];
}

+ (BOOL)hasAppSupportFile:(NSString*)filename{
    return [self fileExistsAtPath:[self appSupportPath:filename]];
}

+ (NSData*)getDataFromFileOfPath:(NSString*)path{
    if ([self fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return data;
    }
    return nil;
}

+ (NSData*)getDataFromFileUrl:(NSURL*)url{
    return [NSData dataWithContentsOfURL:url];
}

+ (id)jsonDataToObject:(NSData*)data{
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingMutableContainers
                                             error:&error];
}

+ (id)jsonStrToObject:(NSString*)str{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [self jsonDataToObject:data];
}

+ (NSData*)objectToJsonData:(id)object{
    @try {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:0
                                                             error:&error];
        return jsonData;
    } @catch (NSException *exception) {
        NSLog(@"[xFile] Convert Object to JSON fail! : %@", object);
        return nil;
    }
}

+ (NSString*)objectToJsonStr:(id)object{
    NSData *jsonData = [self objectToJsonData:object];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSData*)base64ToData:(NSString*)base64{
    return [[NSData alloc] initWithBase64EncodedString:base64 options:0];
}

+ (NSString*)dataToBase64:(NSData*)data{
    return [data base64EncodedStringWithOptions:0];
}

+ (NSString*)strToMD5:(NSString*)str{
    return [self dataToMD5:[str dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString*)dataToMD5:(NSData*)data{
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5);
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X", result[i]];
    }
    return resultString;
}

+ (NSDictionary*)getDicFromFileOfPath:(NSString*)path{
    NSData *data = [self getDataFromFileOfPath:path];
    if (data == nil) {
        return nil;
    }
    NSDictionary* dic = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return dic;
}

+ (void)createFileIfNotExistsAtPath:(NSString*)path{
    if ([self fileExistsAtPath:path]) {
        return;
    }
    NSString *folderPath = [path stringByDeletingLastPathComponent];
    [self createFolder:folderPath];
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

+ (void)appendText:(NSString*)text toFile:(NSString*)path{
    @synchronized (self) {
        [self createFileIfNotExistsAtPath:path];
        NSFileHandle *myHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
        [myHandle closeFile];
    }
}

+ (BOOL)saveData:(NSData*)data toPath:(NSString*)path{
    [self createFileIfNotExistsAtPath:path];
    return [data writeToFile:path atomically:YES];
}

+ (BOOL)saveDic:(NSDictionary*)dic toPath:(NSString*)path{
    if ([self verifyArchivable:dic]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        return [self saveData:data toPath:path];
    }
    return NO;
}

+ (BOOL)deleteFileOfPath:(NSString*)path{
    if (![self fileExistsAtPath:path]) {
        return YES;
    }
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (success) {
        return YES;
    }
    else {
        if (error) {
            NSLog(@"Could not delete file -:%@\n", [error localizedDescription]);
        }
        return NO;
    }
}


+ (BOOL)createFolder:(NSString *)path {
    //当文件夹不存在的时候再创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    else{
        return NO;
    }
}

+ (BOOL)deleteFolder:(NSString *)path {
    if (![self folderExistsAtPath:path]) {
        return YES;
    }
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (success) {
        return YES;
    }
    else {
        if (error) {
            NSLog(@"Could not delete folder -:%@\n", [error localizedDescription]);
        }
        return NO;
    }
}

+ (unsigned long long) fileSize:(NSString *)path{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *fileDictionary = [manager attributesOfItemAtPath:path error:nil];
    unsigned long long int fileSize = [[fileDictionary objectForKey:NSFileSize] unsignedLongLongValue];
    return fileSize;
}

+ (unsigned long long) folderSize:(NSString *)path {
    if (![self folderExistsAtPath:path]) {
        return 0;
    }
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary<NSFileAttributeKey,id> *fileDictionary = [manager attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
        
        if (![fileDictionary[NSFileType] isEqualToString:NSFileTypeDirectory]) {
            fileSize += [[fileDictionary objectForKey:NSFileSize] unsignedLongLongValue];
        }
    }
    return fileSize;
}

+ (BOOL) removeFilesAtFolderPath:(NSString *)path {
    if (![self folderExistsAtPath:path]) {
        return YES;
    }
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    while (fileName = [filesEnumerator nextObject]) {
        [manager removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:&error];
    }
    if (error.code == NSFileNoSuchFileError) {
        //  文件不存在说明其父文件夹已经被删了，视为删除成功
        error = nil;
    }
    return (error == nil ? YES : NO);
}

+ (BOOL)copyFileFromPath:(NSString*)fromPath toPath:(NSString*)toPath{
    if ([self fileExistsAtPath:fromPath]) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error = nil;
        [manager copyItemAtPath:fromPath toPath:toPath error:&error];
        return (error == nil ? YES : NO);
    }
    return NO;
}

+ (BOOL)verifyArchivable:(id)obj {
    __block BOOL valid = YES;
    if ([obj isKindOfClass:[NSArray class]]) {
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![self verifyArchivable:obj]) {
                valid = NO;
                *stop = YES;
            }
        }];
        return valid;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            BOOL keyValid = [self verifyArchivable:key];
            BOOL valueValid = [self verifyArchivable:obj];
            if (!keyValid || !valueValid) {
                valid = NO;
                *stop = YES;
            }
        }];
        return valid;
    } else {
        return [(NSObject *)obj conformsToProtocol:NSProtocolFromString(@"NSCoding")];
    }
}


@end
