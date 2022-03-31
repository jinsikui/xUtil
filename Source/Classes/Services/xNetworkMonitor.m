

#import "xNetworkMonitor.h"

@interface xNetworkMonitor()

@property(nonatomic,strong) NSMapTable *callbackTable;

@end

@implementation xNetworkMonitor

+ (instancetype)shared {
    static xNetworkMonitor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[xNetworkMonitor alloc] init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if(self){
        _callbackTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkStatusChanged) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)startMonitoring{
    [AFNetworkReachabilityManager.sharedManager startMonitoring];
}

-(void)stopMonitoring{
    [AFNetworkReachabilityManager.sharedManager stopMonitoring];
}

-(AFNetworkReachabilityStatus)networkStatus{
    return AFNetworkReachabilityManager.sharedManager.networkReachabilityStatus;
}

-(BOOL)networkOK{
    return self.networkStatus == AFNetworkReachabilityStatusReachableViaWWAN || self.networkStatus == AFNetworkReachabilityStatusReachableViaWiFi;
}

-(void)registerCallbackWithLife:(id)lifeIndicator callback:(void (^)(AFNetworkReachabilityStatus status))callback{
    [_callbackTable setObject:callback forKey:lifeIndicator];
}

-(void)onNetworkStatusChanged{
    AFNetworkReachabilityStatus status = self.networkStatus;
    NSEnumerator *keyEnum = _callbackTable.keyEnumerator;
    id lifeIndicator;
    while (lifeIndicator = [keyEnum nextObject]) {
        void (^callback)(AFNetworkReachabilityStatus status) = [_callbackTable objectForKey:lifeIndicator];
        callback(status);
    }
}

@end
