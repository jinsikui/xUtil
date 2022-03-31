

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 获取用户权限的种类
typedef enum xDevicePermissionType {
    xDevicePermissionTypeMicrophone,        /// 麦克风
    xDevicePermissionTypeCamera,            /// 相机
    xDevicePermissionTypePhotoLibrary,      /// 相册
    xDevicePermissionTypeItunes,            /// iTunes
    xDevicePermissionTypePush,              /// 推送
} xDevicePermissionType;

typedef NSString*_Nonnull(^xDeviceIdProvider)(void);

typedef void(^xDeviceAuthorizeCallback)(BOOL isAuthorized, BOOL isFirstDetermined);

@interface xDevice : NSObject

/// deviceId提供逻辑，没有会用默认逻辑
@property(nonatomic,class,readwrite) xDeviceIdProvider _Nullable deviceIdProvider;

/// 是否时ipad
@property(nonatomic,class,readonly) BOOL isPad;

/// 是否是竖屏
@property(nonatomic,class,readonly) BOOL isPortraitOrientation;

/// 375 <= 宽 <= 414，高 >= 812
@property(nonatomic,class,readonly) BOOL isiPhoneXSeries;

/// 设备型号 例如："iPhone6,1"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModel;

/// 设备名称 例如："iPhone 5s"
/// @see http://theiphonewiki.com/wiki/Models
@property (nullable, nonatomic, readonly) NSString *machineModelName;

/// 屏宽
+ (CGFloat)screenWidth;

/// 屏高
+ (CGFloat)screenHeight;

/// 状态栏高
+ (CGFloat)statusBarHeight;

/// 导航栏高
+ (CGFloat)navBarHeight;

/// 底部safeArea高
+ (CGFloat)bottomBarHeight;

/// 底部safeArea高 + tabbar高度（49）
+ (CGFloat)defaultTabBarHeight;

/// systemVersion去掉最后一个小数点
+ (float)iosVersion;

/// systemVersion
+ (NSString*)iosRawVersion;

/// kCFBundleVersionKey
+ (NSString*)buildVersion;

/// CFBundleShortVersionString
+ (NSString*)appVersion;

/// app名称
+ (NSString*)appDisplayName;

/// 设备名称
+ (NSString*)deviceName;

/// 设备ID
+ (NSString*)deviceId;

/// 包ID
+ (NSString*)bundleId;

/// 请求权限
/// @param type 权限种类
/// @param callback 如果已经授权或拒绝过会立刻回调，否则会请求权限
+ (void)requestPermissionFor:(xDevicePermissionType)type
                    callback:(xDeviceAuthorizeCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
