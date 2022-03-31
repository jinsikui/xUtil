

#import "xNotice.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@implementation NSObject (xNotice)

- (void)setX_notice_disable:(BOOL)x_notice_disable{
    objc_setAssociatedObject(self, @selector(x_notice_disable), @(x_notice_disable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)x_notice_disable{
    NSNumber *x_notice_disable = objc_getAssociatedObject(self, _cmd);
    if (x_notice_disable == nil) {
        return NO;
    }
    return [x_notice_disable boolValue];
}

@end

//===================================================================

static NSString *const kAppFinishLaunching = @"xNotice.AppFinishLaunching";
static NSString *const kAppBecomeActive = @"xNotice.AppBecomeActive";
static NSString *const kAppEnterForeground = @"xNotice.AppEnterForeground";
static NSString *const kAppEnterBackground = @"xNotice.AppEnterBackground";
static NSString *const kAppWillTerminate = @"xNotice.AppWillTerminate";
static NSString *const kAppWillResignActive = @"xNotice.AppWillResignActive";
static NSString *const kAppAudioSessionRouteChange = @"xNotice.AppAudioSessionRouteChange";
static NSString *const kTimerTicking = @"xNotice.TimerTicking";
static NSString *const kRequireSignOut = @"xNotice.RequireSignOut";
static NSString *const kSignIn = @"xNotice.SignIn";

@interface xNotice()

@property(nonatomic,strong) NSMutableDictionary<NSString*, NSMapTable<id, void(^)(id)>*> *actionDic;
@property(nonatomic,strong) dispatch_queue_t                bindQueue;
@property(nonatomic,assign) BOOL    hasRegisterred;

@end

@implementation xNotice

+ (instancetype)shared {
    static xNotice *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[xNotice alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _actionDic = [NSMutableDictionary dictionary];
        _bindQueue =  dispatch_queue_create([@"xNotice.bindQueue" UTF8String], DISPATCH_QUEUE_CONCURRENT);
        [self registerNotices];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)registerNotices {
    if (_hasRegisterred) {
        return;
    }
    _hasRegisterred = true;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appAudioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}


- (void)setAction:(NSString *)key lifeIndicator:(id)lifeIndicator action:(id)action {
    NSMapTable *mapTable = _actionDic[key];
    if (!mapTable) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
        _actionDic[key] = mapTable;
    }
    [mapTable setObject:action forKey:lifeIndicator];
}

- (void)runAction:(NSString *)key param:(id __nullable)param {
    NSMapTable *mapTable = _actionDic[key];
    if (!mapTable) {
        return;
    }
    NSEnumerator *keyEnum = mapTable.keyEnumerator;
    id keyObj;
    while (keyObj = [keyEnum nextObject]) {
        if (((NSObject*)keyObj).x_notice_disable) {
            continue;
        }
        void (^obj)(id __nullable) = [mapTable objectForKey:keyObj];
        obj(param);
    }
}

#pragma mark - Notification handlers

- (void)appFinishLaunching:(NSNotification*)notification{
    dispatch_async(_bindQueue, ^{
        [self runAction:kAppFinishLaunching param:notification.userInfo];
    });
}

- (void)appEnterForeground:(NSNotification*)notification{
    dispatch_async(_bindQueue, ^{
        [self runAction:kAppEnterForeground param:notification.userInfo];
    });
}

- (void)appBecomeActive:(NSNotification*)notification{
    dispatch_async(_bindQueue, ^{
        [self runAction:kAppBecomeActive param:notification.userInfo];
    });
}

- (void)appWillResignActive:(NSNotification*)notification{
    dispatch_async(_bindQueue, ^{
        [self runAction:kAppWillResignActive param:notification.userInfo];
    });
}

- (void)appEnterBackground:(NSNotification*)notification {
    dispatch_async(_bindQueue, ^{
        [self runAction:kAppEnterBackground param:notification.userInfo];
    });
}

- (void)appWillTerminate:(NSNotification*)notification {
    dispatch_async(_bindQueue, ^{
        [self runAction:kAppWillTerminate param:notification.userInfo];
    });
}

- (void)appAudioSessionRouteChange:(NSNotification*)notification {
    dispatch_async(_bindQueue, ^{
        [self runAction:kAppAudioSessionRouteChange param:notification.userInfo];
    });
}

#pragma mark - register methods

- (void)registerAppFinishLaunching:(id)lifeIndicator action:(void(^)(id __nullable))action{
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kAppFinishLaunching lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerAppBecomeActive:(id)lifeIndicator action:(void (^)(id __nullable))action {
    
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kAppBecomeActive lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerAppWillEnterForeground:(id)lifeIndicator action:(void (^)(id __nullable))action {
    
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kAppEnterForeground lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerAppWillResignActive:(id)lifeIndicator action:(void (^)(id __nullable))action {
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kAppWillResignActive lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerAppEnterBackground:(id)lifeIndicator action:(void (^)(id __nullable))action {
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kAppEnterBackground lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerAppWillTerminate:(id)lifeIndicator action:(void (^)(id __nullable))action {
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kAppWillTerminate lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerAppAudioSessionRouteChange:(id)lifeIndicator action:(void (^)(id __nullable))action {
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kAppAudioSessionRouteChange lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerEvent:(NSString*)eventName lifeIndicator:(id)lifeIndicator action:(void (^)(id __nullable))action{
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:eventName lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerRequireSignOut:(id)lifeIndicator action:(void (^)(id __nullable))action{
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kRequireSignOut lifeIndicator:lifeIndicator action:action];
    });
}

- (void)registerSignInWith:(id)lifeIndicator action:(void (^)(id __nullable))action{
    dispatch_barrier_async(_bindQueue, ^{
        [self setAction:kSignIn lifeIndicator:lifeIndicator action:action];
    });
}

#pragma mark - post events

- (void)postEvent:(NSString*)eventName userInfo:(NSDictionary<NSString*, id>* __nullable)userInfo{
    dispatch_barrier_async(_bindQueue, ^{
        [self runAction:eventName param:userInfo];
    });
}

- (void)postRequireSignOutWithToast:(NSString* __nullable)toast{
    dispatch_barrier_async(_bindQueue, ^{
        if (toast != nil && toast.length > 0) {
            [self runAction:kRequireSignOut param:@{kRequireSignOutToast:toast}];
        }
        else{
            [self runAction:kRequireSignOut param:nil];
        }
    });
}

- (void)postSignIn{
    dispatch_barrier_async(_bindQueue, ^{
        [self runAction:kSignIn param:nil];
    });
}

@end
