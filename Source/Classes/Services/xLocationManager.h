

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^xLocationAuthorizeCallback)(BOOL isAuthorized, BOOL isFirstDetermined);

typedef void (^xLocationCallback)(double latitude, double longitude, NSError *_Nullable error);

@interface xLocationManager : NSObject

+ (instancetype)shared;

@property(nonatomic,assign,readonly) CLAuthorizationStatus authStatus;
@property(nonatomic,assign,readonly) BOOL isAuthorized;
@property(nonatomic,assign,readonly) double latitude;
@property(nonatomic,assign,readonly) double longitude;

- (void)requestLocationAuthorization:(xLocationAuthorizeCallback _Nullable)callback;

- (void)registerCallbackWithLife:(id)lifeIndicator callback:(xLocationCallback)callback;

@end

NS_ASSUME_NONNULL_END
