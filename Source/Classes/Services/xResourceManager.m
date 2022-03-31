

#import "xResourceManager.h"
#import "xFile.h"
#import "xNetworkMonitor.h"
#import "xExtensions.h"
#import "xDefines.h"

static NSString *completeFileName = @".xDownloaded";
static NSString *lockFileName = @".xLocked";
static int prefetchMaxFailTimes = 5;

@class xResourceContext;

typedef void (^xResourceDownloadResultCallback)(xResourceContext*);

typedef enum xResourceDownloadState{
    xResourceDownloadStateWaiting = 0,
    xResourceDownloadStateDownloading = 1,
    xResourceDownloadStateCompleted = 2,
    xResourceDownloadStateFail = 3
} xResourceDownloadState;

@interface xResourceContext : NSObject
@property(nonatomic,copy) NSString *rootDir;
@property(nonatomic,copy) NSString *url;
@property(nonatomic,copy) NSString *key;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *folderPath;
@property(nonatomic,copy) NSString *downloadFilePath;
/// 标识下载完成的文件
@property(nonatomic,copy) NSString *completeFilePath;
@property(nonatomic,assign) xResourceDownloadState state;
@property(nonatomic,assign,readonly) BOOL isCompleted;
@property(nonatomic,strong) FBLPromise *promise;
@property(nonatomic,assign) int failTimes;
/// 达到后，不再重启prefetch，当然如果外界调getResource还是要再尝试下载的
@property(nonatomic,assign) int prefetchMaxFailTimes;
@property(nonatomic,copy) xResourceDownloadResultCallback downloadResultCallback;

-(instancetype)initWithRootDir:(NSString*)rootDir
                           url:(NSString*)url;
@end

@implementation xResourceContext

-(instancetype)initWithRootDir:(NSString*)rootDir
                           url:(NSString*)url{
    self = [super init];
    if(self){
        self.rootDir = rootDir;
        self.url = url;
        self.key = [xFile strToMD5:url];
        self.name = [url lastPathComponent];
        self.folderPath = [rootDir stringByAppendingPathComponent:self.key];
        self.downloadFilePath = [self.folderPath stringByAppendingPathComponent:self.name];
        self.completeFilePath = [self.folderPath stringByAppendingPathComponent:completeFileName];
        self.prefetchMaxFailTimes = prefetchMaxFailTimes;
        [self loadCompleteStateFromFile];
    }
    return self;
}

-(void)loadCompleteStateFromFile{
    @synchronized (self) {
        if([xFile fileExistsAtPath:self.completeFilePath]){
            self.state = xResourceDownloadStateCompleted;
        }
    }
}

-(BOOL)isCompleted{
    @synchronized (self) {
        return self.state == xResourceDownloadStateCompleted;
    }
}

-(BOOL)isReadyForPrefetch{
    @synchronized (self) {
        return self.state == xResourceDownloadStateWaiting || (self.state == xResourceDownloadStateFail && self.failTimes < self.prefetchMaxFailTimes);
    }
}

-(FBLPromise<NSString*>*)getResource{
    @synchronized (self) {
        if(self.state == xResourceDownloadStateCompleted){
            return [self x_fulfilledPromise:self.downloadFilePath];
        }
        else if(self.state == xResourceDownloadStateFail || self.state == xResourceDownloadStateWaiting){
            self.state = xResourceDownloadStateDownloading;
            [xFile createFolder:self.folderPath];
            NSString *completeFilePath = self.completeFilePath;
            __weak xResourceContext *weak = self;
            self.promise = [self x_downloadFilePromise:self.url downloadFilePath:self.downloadFilePath].then(^id(NSString *path){
                //创建标识下载完成的文件
                [xFile createFileIfNotExistsAtPath:completeFilePath];
                __strong xResourceContext *s = weak;
                if(s){
                    @synchronized (s) {
                        s.state = xResourceDownloadStateCompleted;
                        s.failTimes = 0;
                    }
                }
                return path;
            }).catch(^(NSError *error){
                __strong xResourceContext *s = weak;
                if(s){
                    @synchronized (s) {
                        s.failTimes ++;
                        s.state = xResourceDownloadStateFail;
                    }
                }
            }).always(^{
                __strong xResourceContext *s = weak;
               if(s){
                   xResourceDownloadResultCallback callback = s.downloadResultCallback;
                   if(callback){
                       callback(s);
                   }
               }
            });
            return self.promise;
        }
        else{
            //downloading
            return self.promise;
        }
    }
}
@end


@interface xResourceManager()
@property(nonatomic,copy,readwrite) NSString *rootDirPath;
@property(nonatomic,strong,readonly) NSMutableDictionary<NSString*, xResourceContext*> *allTaskMap;
@property(nonatomic,strong,readonly) NSMutableArray<xResourceContext*> *prefetchQueue;
@end

@implementation xResourceManager

+(instancetype)resourceManagerForRootDir:(NSString*)rootDirPath{
    xResourceManager *m = [[xResourceManager alloc] initWithRootDir:rootDirPath];
    return m;
}

+(instancetype)resourceManagerForCategory:(NSString*)category{
    return [self resourceManagerForRootDir:[xFile appSupportPath:category]];
}

-(instancetype)initWithRootDir:(NSString*)rootDir{
    self = [super init];
    if(self){
        _rootDirPath = rootDir;
        [xFile createFolder:_rootDirPath];
        _allTaskMap = [NSMutableDictionary new];
        _prefetchQueue = [NSMutableArray new];
        __weak xResourceManager *weak = self;
        [xNetworkMonitor.shared registerCallbackWithLife:self callback:^(AFNetworkReachabilityStatus status) {
            __strong xResourceManager *s = weak;
            if(s){
                [s networkChanged:status];
            }
        }];
    }
    return self;
}

-(NSString*)folderNameForUrl:(NSString*)url{
    return [xFile strToMD5:url];
}

-(NSString*)folderPathForUrl:(NSString*)url{
    NSString *folderName = [self folderNameForUrl:url];
    NSString *folderPath = [_rootDirPath stringByAppendingPathComponent:folderName];
    return folderPath;
}

-(NSString*)downloadFilePathForUrl:(NSString*)url{
    NSString *name = [url lastPathComponent];
    NSString *folderPath = [self folderPathForUrl:url];
    return [folderPath stringByAppendingPathComponent:name];
}

-(BOOL)isCompletedForFolderPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url{
    NSString *completeFilePath;
    if(x_str_not_null(folderPath)){
        completeFilePath = [folderPath stringByAppendingPathComponent:completeFileName];
    }
    else if(x_str_not_null(url)){
        completeFilePath = [[self folderPathForUrl:url] stringByAppendingPathComponent:completeFileName];
    }
    if(x_str_not_null(completeFilePath)){
        return [xFile fileExistsAtPath:completeFilePath];
    }
    return false;
}

-(void)networkChanged:(AFNetworkReachabilityStatus)status{
    [self startPrefetchIfAvailable];
}

-(BOOL)isPrefetchAvailable{
    AFNetworkReachabilityStatus status = xNetworkMonitor.shared.networkStatus;
    return (status == AFNetworkReachabilityStatusReachableViaWiFi || (status == AFNetworkReachabilityStatusReachableViaWWAN && self.isPrefetchOnWWAN));
}

-(void)startPrefetchIfAvailable{
    @synchronized (self) {
        [self _startPrefetchIfAvailable];
    }
}

-(void)_startPrefetchIfAvailable{
    if(self.isPrefetchAvailable){
        if(!self.isConcurrentPrefetch){
            //串行预加载
            if(self.prefetchQueue.count > 0){
                xResourceContext *c = self.prefetchQueue[0];
                if(c.isReadyForPrefetch){
                    [c getResource];
                }
            }
        }
        else{
            //并行预加载
            for(xResourceContext *c in self.prefetchQueue){
                if(c.isReadyForPrefetch){
                    [c getResource];
                }
            }
        }
    }
}

-(void)downloadGotResult:(xResourceContext*)c{
    @synchronized (self) {
        if([_prefetchQueue containsObject:c]){
            if(c.isCompleted){
                [_prefetchQueue removeObject:c];
            }
            else if(c.state == xResourceDownloadStateFail){
                if(c.failTimes >= c.prefetchMaxFailTimes){
                    [_prefetchQueue removeObject:c];
                }
                else{
                    //移动至队尾
                    [_prefetchQueue removeObject:c];
                    [_prefetchQueue addObject:c];
                }
            }
            [self _startPrefetchIfAvailable];
        }
    }
}

-(xResourceContext*)createContext:(NSString*)url{
    __weak xResourceManager *weak = self;
    xResourceContext *c = [[xResourceContext alloc] initWithRootDir:self.rootDirPath url:url];
    c.downloadResultCallback = ^(xResourceContext *context) {
        __strong xResourceManager *s = weak;
        if(s){
            [s downloadGotResult:context];
        }
    };
    return c;
}

-(void)prefetchUrls:(NSArray<NSString*>*)urls{
    @synchronized (self) {
        NSMutableArray<xResourceContext*> *newTasks = [NSMutableArray new];
        for(NSString *url in urls){
            if(_allTaskMap[url] == nil){
                xResourceContext *c = [self createContext:url];
                _allTaskMap[url] = c;
                if(!c.isCompleted){
                    [newTasks addObject:c];
                }
            }
        }
        if(newTasks.count > 0){
            [_prefetchQueue addObjectsFromArray:newTasks];
            [self _startPrefetchIfAvailable];
        }
    }
}

-(void)prefetchUrl:(NSString*)url{
    [self prefetchUrls:@[url]];
}

-(FBLPromise<NSString*>*)getUrl:(NSString*)url{
    @synchronized (self) {
        xResourceContext *c = _allTaskMap[url];
        if(!c){
            c = [self createContext:url];
            _allTaskMap[url] = c;
            if(!c.isCompleted){
                [_prefetchQueue addObject:c];
            }
        }
        return [c getResource];
    }
}

#pragma mark - Lock & clean

-(NSString*)getLockFilePathForFolderPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url{
    NSString *lockFilePath;
    if(x_str_not_null(folderPath)){
        lockFilePath = [folderPath stringByAppendingPathComponent:lockFileName];
    }
    else if(x_str_not_null(url)){
        lockFilePath = [[_rootDirPath stringByAppendingPathComponent:[self folderNameForUrl:url]] stringByAppendingPathComponent:lockFileName];
    }
    return lockFilePath;
}

/// 防止clean时删除
-(void)lockFolderForPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url{
    NSString *lockFilePath = [self getLockFilePathForFolderPath:folderPath orUrl:url];
    if(x_str_not_null(lockFilePath)){
        [xFile createFileIfNotExistsAtPath:lockFilePath];
    }
}

-(void)unlockFolderForPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url{
    NSString *lockFilePath = [self getLockFilePathForFolderPath:folderPath orUrl:url];
    if(x_str_not_null(lockFilePath)){
        [xFile deleteFileOfPath:lockFilePath];
    }
}

-(BOOL)isFolderLockedForPath:(NSString*_Nullable)folderPath orUrl:(NSString*_Nullable)url{
    NSString *lockFilePath = [self getLockFilePathForFolderPath:folderPath orUrl:url];
    if(x_str_not_null(lockFilePath)){
        return [xFile fileExistsAtPath:lockFilePath];
    }
    return false;
}

/// 对于rootDir下所有文件夹执行清理，只清理已经下载完成且没有被锁定的文件夹
-(void)clean{
    @synchronized (self) {
        NSMutableArray<NSString*> *deletedFolderNames = [NSMutableArray new];
        NSArray *itemsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:_rootDirPath error:nil];
        NSEnumerator *itemsEnumerator = [itemsArray objectEnumerator];
        NSString *folderName;
        while (folderName = [itemsEnumerator nextObject]) {
            NSString *folderPath = [_rootDirPath stringByAppendingPathComponent:folderName];
            if([self isCompletedForFolderPath:folderPath orUrl:nil] && ![self isFolderLockedForPath:folderPath orUrl:nil]){
                [xFile deleteFolder:folderPath];
                [deletedFolderNames addObject:folderName];
            }
        }
        for(NSString *url in _allTaskMap.allKeys){
            NSString *folderNameForUrl = [self folderNameForUrl:url];
            if([deletedFolderNames containsObject:folderNameForUrl]){
                [_allTaskMap removeObjectForKey:url];
                xResourceContext *c = [_prefetchQueue x_first:^BOOL(xResourceContext * _Nonnull item) {
                    return [item.url isEqualToString:url];
                }];
                if(c){
                    [_prefetchQueue removeObject:c];
                }
            }
        }
    }
}

@end

