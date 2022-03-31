

#import "xLocationManager.h"
#import <UIKit/UIKit.h>

@interface xLocationManager()<CLLocationManagerDelegate>

@property(nonatomic,strong) CLLocationManager *manager;
@property(nonatomic,strong) NSMapTable *callbackTable;
@property(nonatomic,copy) xLocationAuthorizeCallback authCallback;
@property(nonatomic,assign) BOOL authIsFirstDetermined;

@end

@implementation xLocationManager

+ (instancetype) shared {
    static xLocationManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[xLocationManager alloc] init];
    });
    return shared;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _callbackTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableCopyIn];
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        //控制定位精度,越高耗电量越
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)registerCallbackWithLife:(id)lifeIndicator callback:(xLocationCallback)callback{
    [_callbackTable setObject:callback forKey:lifeIndicator];
}

//请求定位服务授权（同时开始定位）
- (void)requestLocationAuthorization:(xLocationAuthorizeCallback _Nullable)callback{
    NSLog(@"===== requestLocationAuthorization: =====");
    if(self.isAuthorized){
        if(callback){
            callback(true, false);
        }
        if ([CLLocationManager locationServicesEnabled]) {
            [self.manager stopUpdatingLocation];
            [self.manager startUpdatingLocation];
        }
        return;
    }
    self.authCallback = callback;
    self.authIsFirstDetermined = (self.authStatus == kCLAuthorizationStatusNotDetermined);
    [_manager requestWhenInUseAuthorization];
    [_manager requestAlwaysAuthorization];
}

- (CLAuthorizationStatus)authStatus{
    return CLLocationManager.authorizationStatus;
}

- (BOOL)isAuthorized{
    return self.authStatus == kCLAuthorizationStatusAuthorizedAlways || self.authStatus == kCLAuthorizationStatusAuthorizedWhenInUse;
}

#pragma mark - Delegate

//定位服务状态改变时

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"===== locationManager:didChangeAuthorizationStatus:%d =====", status);
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"用户还未决定授权");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"访问受限");
            break;
        case kCLAuthorizationStatusDenied:
            //判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"获得前后台授权");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"获得前台授权");
            break;
        default:
            break;
    }
    xLocationAuthorizeCallback callback = self.authCallback;
    if(callback){
        BOOL isAuth = self.isAuthorized;
        BOOL isFirstDetermined = self.authIsFirstDetermined;
        callback(isAuth, isFirstDetermined);
        self.authCallback = nil;
    }
    if(self.isAuthorized){
        if ([CLLocationManager locationServicesEnabled]) {
            [self.manager stopUpdatingLocation];
            [self.manager startUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"===== locationManager:didUpdateLocations: =====");
    CLLocation *loc = [locations lastObject];
    CLLocationCoordinate2D l = loc.coordinate;
    double lat = l.latitude;
    double lnt = l.longitude;
    _latitude = lat;
    _longitude = lnt;
    NSEnumerator *keyEnum = _callbackTable.keyEnumerator;
    id lifeIndicator;
    while (lifeIndicator = [keyEnum nextObject]) {
        xLocationCallback callback = [_callbackTable objectForKey:lifeIndicator];
        if(callback){
            callback(lat,lnt, nil);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"===== locationManager:didFailWithError:%@ =====", error);
    NSEnumerator *keyEnum = _callbackTable.keyEnumerator;
    id lifeIndicator;
    while (lifeIndicator = [keyEnum nextObject]) {
        xLocationCallback callback = [_callbackTable objectForKey:lifeIndicator];
        if(callback){
            callback(0, 0, error);
        }
    }
}

@end
