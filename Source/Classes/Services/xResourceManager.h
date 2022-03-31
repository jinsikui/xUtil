

#import <Foundation/Foundation.h>
#if __has_include(<FBLPromises/FBLPromises.h>)
#import <FBLPromises/FBLPromises.h>
#else
#import "FBLPromises.h"
#endif


NS_ASSUME_NONNULL_BEGIN

/// 资源下载管理器
/// 每个url下载后的存放路径是r<ootDirPath>/<md5(url)>/<lastPathComponent(url)>
/// 所有的下载在global线程进行
@interface xResourceManager : NSObject

+(instancetype)resourceManagerForRootDir:(NSString*)rootDirPath;
/// rootDir为<app support dir>/<category>
+(instancetype)resourceManagerForCategory:(NSString*)category;

@property(nonatomic,copy,readonly) NSString *rootDirPath;

/// 是否移动网络下也进行预加载，默认false
/// false：wifi下才会预加载，切换移动网络不会停止正在进行的下载，切换wifi会重启未完成下载
/// true：移动网络也会预加载，无网->有网会重启未完成下载
@property(nonatomic,assign) BOOL isPrefetchOnWWAN;
/// 是否并行下载，默认false，即串行下载
@property(nonatomic,assign) BOOL isConcurrentPrefetch;

/// 预加载urls
-(void)prefetchUrls:(NSArray<NSString*>*)urls;
/// 预加载url
-(void)prefetchUrl:(NSString*)url;

-(NSString*)folderNameForUrl:(NSString*)url;

-(NSString*)folderPathForUrl:(NSString*)url;

-(NSString*)downloadFilePathForUrl:(NSString*)url;

-(BOOL)isCompletedForFolderPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url;

/// 获取url对应的资源，返回下载后路径
-(FBLPromise<NSString*>*)getUrl:(NSString*)url;

#pragma mark - Lock & clean

/// 防止clean时删除
-(void)lockFolderForPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url;

-(void)unlockFolderForPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url;

-(BOOL)isFolderLockedForPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url;

/// 对于rootDir下所有文件夹执行清理，只清理已经下载完成且没有被锁定的文件夹
-(void)clean;

@end

NS_ASSUME_NONNULL_END
