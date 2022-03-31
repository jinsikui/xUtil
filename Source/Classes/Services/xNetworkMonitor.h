

#import <Foundation/Foundation.h>
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface xNetworkMonitor : NSObject

+ (instancetype)shared;

-(void)startMonitoring;

-(void)stopMonitoring;

@property(nonatomic,readonly) AFNetworkReachabilityStatus networkStatus;
@property(nonatomic,readonly) BOOL networkOK;

-(void)registerCallbackWithLife:(id)lifeIndicator callback:(void (^)(AFNetworkReachabilityStatus status))callback;

@end

NS_ASSUME_NONNULL_END
