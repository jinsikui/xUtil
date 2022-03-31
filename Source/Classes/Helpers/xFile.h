

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface xFile : NSObject

/// 生成沙盒document下路径
/// @param filename 文件名
+ (NSString *)documentPath:(NSString *)filename;

/// 生成沙盒temp下路径
/// @param filename 文件名
+ (NSString *)tmpPath:(NSString *)filename;

/// 生成沙盒cache下路径
/// @param filename 文件名
+ (NSString *)cachePath:(NSString *)filename;

/// 生成沙盒appSupport下路径
/// @param filename 文件名
+ (NSString *)appSupportPath:(NSString *)filename;

/// mainBundle下文件路径
/// @param filename 文件名
+ (nullable NSString *)bundlePath:(NSString *)filename;

/// 文件是否存在
/// @param path 路径
+ (BOOL)fileExistsAtPath:(NSString *)path;

/// 文件夹是否存在
/// @param path 路径
+ (BOOL)folderExistsAtPath:(NSString *)path;

/// 文件是否在沙盒document文件夹存在
/// @param filename 文件名
+ (BOOL)hasDocumentFile:(NSString *)filename;

/// 文件是否在沙盒cache文件夹存在
/// @param filename 文件名
+ (BOOL)hasCacheFile:(NSString *)filename;

/// 文件是否在沙盒appSupport文件夹存在
/// @param filename 文件名
+ (BOOL)hasAppSupportFile:(NSString *)filename;

/// 获取文件data
/// @param path 路径
+ (nullable NSData *)getDataFromFileOfPath:(NSString *)path;

/// 获取文件data
/// @param url 路径
+ (nullable NSData *)getDataFromFileUrl:(NSURL *)url;

/// data转json
+ (nullable id)jsonDataToObject:(NSData *)data;

/// str转json
+ (nullable id)jsonStrToObject:(NSString *)str;

/// 对象转json
+ (nullable NSData *)objectToJsonData:(id)object;

/// 对象转json转str
+ (nullable NSString *)objectToJsonStr:(id)object;

/// base64str转data
+ (nullable NSData *)base64ToData:(NSString *)base64;

/// base64data转str
+ (NSString *)dataToBase64:(NSData *)data;

/// 字符串md5
+ (NSString *)strToMD5:(NSString *)str;

/// data转md5字符串
+ (NSString *)dataToMD5:(NSData *)data;

/// 获取data并unarchive
+ (nullable NSDictionary *)getDicFromFileOfPath:(NSString *)path;

/// 创建file若file不存在
+ (void)createFileIfNotExistsAtPath:(NSString *)path;

/// 在file末尾添加字符串
/// @param text 要添加的字符串
/// @param path 文件路径
+ (void)appendText:(NSString *)text toFile:(NSString *)path;

/// 在file中写入data
+ (BOOL)saveData:(NSData *)data toPath:(NSString *)path;

/// archive存入字典
/// @param dic root字典
/// @param path 路径
+ (BOOL)saveDic:(NSDictionary *)dic toPath:(NSString *)path;

/// 删除路径下文件
/// @param path 路径
+ (BOOL)deleteFileOfPath:(NSString *)path;

/// 创建文件夹，不存在才会创建
/// @param path 路径
+ (BOOL)createFolder:(NSString *)path;

/// 删除文件夹
/// @param path 路径
+ (BOOL)deleteFolder:(NSString *)path;

/// 文件大小
/// @param path 路径
+ (unsigned long long)fileSize:(NSString *)path;

/// 文件夹大小
/// @param path 路径
+ (unsigned long long)folderSize:(NSString *)path;

/// 删除文件夹
/// @param path 路径
+ (BOOL)removeFilesAtFolderPath:(NSString *)path;

/// copy文件到目标路径
/// @param fromPath 文件路径
/// @param toPath 目标路径
+ (BOOL)copyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

///  Object是否可以被归档
/// @param obj 需要检查的Object
+ (BOOL)verifyArchivable:(id)obj;

@end

NS_ASSUME_NONNULL_END
