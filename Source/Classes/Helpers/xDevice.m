

#import "xDevice.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "xTask.h"
#import "xDefines.h"
#import "xKeychainStore.h"
#import "xFile.h"
#import <UserNotifications/UserNotifications.h>
#import <AdSupport/AdSupport.h>
#include <sys/sysctl.h>

static float _iosVersion = -1;
static CGFloat _screenWidth = -1;
static CGFloat _screenHeight = -1;
static NSString *_deviceId = nil;
static NSString *_bundleId = nil;
static NSString *_buildVersion = nil;
static NSString *_appVersion = nil;
static NSString *_appDisplayName = nil;
static xDeviceIdProvider _deviceIdProvider = nil;

@implementation xDevice

+ (BOOL)isPad{
    static dispatch_once_t one;
    static BOOL pad;
    dispatch_once(&one, ^{
        pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return pad;
}

+ (BOOL)isPortraitOrientation{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
}

+ (BOOL)isiPhoneXSeries {
    // 宽高都会变化，以后可能变的更大，但最小的都有以下的值
    return ([UIScreen mainScreen].bounds.size.width >= 375 && [UIScreen mainScreen].bounds.size.width <= 414 && [UIScreen mainScreen].bounds.size.height >= 812);
}

+ (CGFloat)safeStatusBarHeight {
    NSString *machineName = [self machineModelName];
    if ([machineName isEqualToString:@"iPhone X"] ||
        [machineName isEqualToString:@"iPhone XS"] ||
        [machineName isEqualToString:@"iPhone XS Max"] ||
        [machineName isEqualToString:@"iPhone XR"] ||
        [machineName isEqualToString:@"iPhone 11 Pro"] ||
        [machineName isEqualToString:@"iPhone 11 Pro Max"]) {
        return 44.0;
    } else if ([machineName isEqualToString:@"iPhone 12"] ||
               [machineName isEqualToString:@"iPhone 12 Pro"] ||
               [machineName isEqualToString:@"iPhone 12 Pro Max"]) {
        return 47.0;
    } else if ([machineName isEqualToString:@"iPhone 11"]) {
        return 48.0;
    } else if ([machineName isEqualToString:@"iPhone 12 mini"]) {
        return 50.0;
    }  else {
        return 20.0;
    }
}

+ (CGFloat)screenWidth{
    if (self.isPad) {
        CGFloat screenWidth;
        if (self.isPortraitOrientation) {
            screenWidth = [UIScreen mainScreen].bounds.size.width;
        }else{
            screenWidth = [UIScreen mainScreen].bounds.size.height;
        }
        return screenWidth - 90 - 30.0 * 2;
    }
    else{
        if (_screenWidth < 0) {
            _screenWidth = [UIScreen mainScreen].bounds.size.width;
        }
        return _screenWidth;
    }
}

+ (CGFloat)screenHeight{
    if (self.isPad) {
        CGFloat paddingTop = 54.0;
        CGFloat paddingBottom = 0;
        if (@available(iOS 11.0, *)) {
            paddingBottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        }
        paddingBottom = MAX(30.0, paddingBottom);
        return [UIScreen mainScreen].bounds.size.height - paddingTop - paddingBottom;
    }
    else{
        if (_screenHeight < 0) {
            _screenHeight = [UIScreen mainScreen].bounds.size.height;
        }
        return _screenHeight;
    }
}

+ (CGFloat)statusBarHeight{
    if ([self isSimulator]) {
        CGFloat height = 0;
        if (@available(iOS 11.0, *)) {
            height = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        } else {
            height = [UIApplication sharedApplication].keyWindow.rootViewController.topLayoutGuide.length;
        }
        if (height == 0) {
            // 有隐患，如果是从推送打开 App，可能还不存在 keyWindow
            // 有时候会获取不到statusBar height，这里给个默认值兜一下。其实应该在viewWillLayoutSubviews之后再取这个值的，现在有一些地方在viewDidLoad里面取了，会获取不到
            if ([self isiPhoneXSeries]) {
                return 44.0;
            } else {
                return 20.0;
            }
        }
        return height;
    } else {
        return [self safeStatusBarHeight];
    }
}

+ (CGFloat)navBarHeight{
    return 44;
}

+ (CGFloat)bottomBarHeight{
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    } else {
        return [UIApplication sharedApplication].keyWindow.rootViewController.bottomLayoutGuide.length;
    }
}

+ (CGFloat)defaultTabBarHeight{
    return 49.f + [self bottomBarHeight];
}

+ (float)iosVersion{
    if (_iosVersion < 0) {
        NSString *str = [UIDevice currentDevice].systemVersion;
        //convert like "10.3.1" -> "10.3"
        NSRange range = NSMakeRange(0,str.length);
        NSRange found;
        NSInteger foundCount = 0;
        while (range.location < str.length) {
            found = [str rangeOfString:@"." options:0 range:range];
            if (found.location != NSNotFound) {
                foundCount += 1;
                if (foundCount == 2) {
                    str = [str substringToIndex:found.location];
                    break;
                }
                range.location = found.location + found.length;
                range.length = str.length - range.location;
            } else {
                // no more substring to find
                break;
            }
        }
        _iosVersion = str.floatValue;
    }
    return _iosVersion;
}

+ (NSString*)iosRawVersion{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString*)buildVersion{
    if (_buildVersion) {
        return _buildVersion;
    }
    _buildVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    return _buildVersion;
}

+ (NSString*)appVersion{
    if (_appVersion) {
        return _appVersion;
    }
    _appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: @"";
    return _appVersion;
}

+ (NSString*)appDisplayName{
    if (_appDisplayName) {
        return _appDisplayName;
    }
    _appDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (x_str_not_null(_appDisplayName)) {
      return _appDisplayName;
    }
    _appDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] ?: @"";
    return _appDisplayName;
}

+ (NSString*)deviceName{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (void)setDeviceIdProvider:(xDeviceIdProvider)deviceIdProvider{
    _deviceIdProvider = deviceIdProvider;
}

+ (xDeviceIdProvider)deviceIdProvider{
    return _deviceIdProvider;
}

+ (NSString*)deviceId{
    xDeviceIdProvider p = _deviceIdProvider;
    if(p){
        return p();
    }
    static NSString *_deviceId;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static NSString *deviceIdKey = @"X_DEVICE_ID_KEY";
        _deviceId = xKeychainStore.defaultStore[deviceIdKey];
        if (!_deviceId) {
            //获取idfa（用户关闭再打开广告跟踪权限后会改变，卸载重装不会变）
            NSUUID *uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
            if ([[uuid UUIDString] isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
                //idfa 被用户禁止了情况下使用idfv（卸载重装会变）
                uuid = [UIDevice currentDevice].identifierForVendor;
            }
            _deviceId = [[xFile strToMD5:uuid.UUIDString] lowercaseString];
            //保存在keychain中，keychain数据即使用户卸载app也不会消失，为了尽可能保持deviceId不变
            xKeychainStore.defaultStore[deviceIdKey] = _deviceId;
        }
    });
    return _deviceId;
}


+ (NSString*)bundleId{
    if (_bundleId == nil) {
        _bundleId = [[NSBundle mainBundle] bundleIdentifier];
    }
    return _bundleId;
}

+ (void)requestPermissionFor:(xDevicePermissionType)type callback:(xDeviceAuthorizeCallback)callback {
    [xTask executeMain:^{
        if (type == xDevicePermissionTypePhotoLibrary) {
            BOOL isFirstDetermined = false;
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusNotDetermined) {
                isFirstDetermined = true;
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    [xTask executeMain:^{
                        if (status == PHAuthorizationStatusAuthorized) {
                            if (callback) {
                                callback(true, isFirstDetermined);
                            }
                        } else {
                            if (callback) {
                                callback(false, isFirstDetermined);
                            }
                        }
                    }];
                }];
            }
            else if (status == PHAuthorizationStatusAuthorized) {
                if (callback) {
                    callback(true, isFirstDetermined);
                }
            }
            else{
                if (callback) {
                    callback(false, isFirstDetermined);
                }
            }
        }
        else if (type == xDevicePermissionTypeCamera) {
            BOOL isFirstDetermined = false;
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (status == AVAuthorizationStatusNotDetermined) {
                BOOL isFirstDetermined = true;
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    [xTask executeMain:^{
                        if (granted) {
                            if (callback) {
                                callback(true, isFirstDetermined);
                            }
                        }
                        else {
                            if (callback) {
                                callback(false, isFirstDetermined);
                            }
                        }
                    }];
                }];
            }
            else if (status == AVAuthorizationStatusAuthorized) {
                if (callback) {
                    callback(true, isFirstDetermined);
                }
            }
            else{
                if (callback) {
                    callback(false, isFirstDetermined);
                }
            }
        }
        else if (type == xDevicePermissionTypeMicrophone) {
            BOOL isFirstDetermined = false;
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            if (status == AVAuthorizationStatusNotDetermined) {
                isFirstDetermined = true;
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    [xTask executeMain:^{
                        if (granted) {
                            if (callback) {
                                callback(true, isFirstDetermined);
                            }
                        }
                        else {
                            if (callback) {
                                callback(false, isFirstDetermined);
                            }
                        }
                    }];
                }];
            }
            else if (status == AVAuthorizationStatusAuthorized) {
                if (callback) {
                    callback(true, isFirstDetermined);
                }
            }
            else{
                if (callback) {
                    callback(false, isFirstDetermined);
                }
            }
        }
        else if (type == xDevicePermissionTypeItunes) {
            BOOL isFirstDetermined = false;
            if (@available(iOS 9.3, *)) {
                MPMediaLibraryAuthorizationStatus status = [MPMediaLibrary authorizationStatus];
                if (status == MPMediaLibraryAuthorizationStatusNotDetermined) {
                    BOOL isFirstDetermined = true;
                    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                        [xTask executeMain:^{
                            if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                                if (callback) {
                                    callback(true, isFirstDetermined);
                                }
                            } else {
                                if (callback) {
                                    callback(false, isFirstDetermined);
                                }
                            }
                        }];
                    }];
                }
                else if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                    if (callback) {
                        callback(true, isFirstDetermined);
                    }
                }
                else {
                    if (callback) {
                        callback(false, isFirstDetermined);
                    }
                }
            } else{
                if (callback) {
                    callback(true, isFirstDetermined);
                }
            }
        }
        else if (type == xDevicePermissionTypePush) {
            BOOL isFirstDetermined = false;
            UIUserNotificationType types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
            if (types == UIUserNotificationTypeNone) {
                isFirstDetermined = true;
                if (@available(iOS 10.0, *)) {
                    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        [xTask executeMain:^{
                            if (granted) {
                                if(callback){
                                    callback(true, isFirstDetermined);
                                }
                            } else {
                                if (callback) {
                                    callback(false, isFirstDetermined);
                                }
                            }
                        }];
                    }];
                }
                else if (@available(iOS 8.0, *)) {
                    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
                    UIUserNotificationType types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
                    if (types == UIUserNotificationTypeNone) {
                        if(callback){
                            callback(false, isFirstDetermined);
                        }
                    } else {
                        if (callback) {
                            callback(true, isFirstDetermined);
                        }
                    }
                }
                else {
                    if(callback){
                        callback(true, isFirstDetermined);
                    }
                }
                
            }
    }
    }];
}

+ (BOOL)isSimulator {
    static dispatch_once_t one;
    static BOOL simu;
    static BOOL simu2;
    dispatch_once(&one, ^{
        simu = NSNotFound != [[UIDevice currentDevice].model rangeOfString:@"Simulator"].location;
        if (!simu) {
            simu2 = NSNotFound != [self.machineModelName rangeOfString:@"Simulator"].location;
        }
    });
   return simu || simu2;
}

+ (NSString *)machineModel {
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

+ (NSString *)machineModelName {
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self machineModel];
        if (!model) return;
        NSDictionary *dic = @{
            // simulator
            @"i386" : @"Simulator x86",
            @"x86_64" : @"Simulator x64",
            
            // AirPods
            @"AirPods1,1" : @"AirPods",
            @"AirPods2,1" : @"AirPods (2nd generation)",
            @"iProd8,1" : @"AirPods Pro",
            
            // Apple TV
            @"AppleTV2,1" : @"Apple TV (2nd generation)",
            @"AppleTV3,1" : @"Apple TV (3rd generation)",
            @"AppleTV3,2" : @"Apple TV (3rd generation)",
            @"AppleTV5,3" : @"Apple TV (4th generation)",
            @"AppleTV6,2" : @"Apple TV 4K",
            
            // Apple Watch
            @"Watch1,1" : @"Apple Watch (1st generation)",
            @"Watch1,2" : @"Apple Watch (1st generation)",
            @"Watch2,6" : @"Apple Watch Series 1",
            @"Watch2,7" : @"Apple Watch Series 1",
            @"Watch2,3" : @"Apple Watch Series 2",
            @"Watch2,4" : @"Apple Watch Series 2",
            @"Watch3,1" : @"Apple Watch Series 3",
            @"Watch3,2" : @"Apple Watch Series 3",
            @"Watch3,3" : @"Apple Watch Series 3",
            @"Watch3,4" : @"Apple Watch Series 3",
            @"Watch4,1" : @"Apple Watch Series 4",
            @"Watch4,2" : @"Apple Watch Series 4",
            @"Watch4,3" : @"Apple Watch Series 4",
            @"Watch4,4" : @"Apple Watch Series 4",
            @"Watch5,1" : @"Apple Watch Series 5",
            @"Watch5,2" : @"Apple Watch Series 5",
            @"Watch5,3" : @"Apple Watch Series 5",
            @"Watch5,4" : @"Apple Watch Series 5",
            @"Watch5,9" : @"Apple Watch SE",
            @"Watch5,10" : @"Apple Watch SE",
            @"Watch5,11" : @"Apple Watch SE",
            @"Watch5,12" : @"Apple Watch SE",
            @"Watch6,1" : @"Apple Watch Series 6",
            @"Watch6,2" : @"Apple Watch Series 6",
            @"Watch6,3" : @"Apple Watch Series 6",
            @"Watch6,4" : @"Apple Watch Series 6",
            
            // HomePod
            @"AudioAccessory1,1" : @"HomePod",
            @"AudioAccessory1,2" : @"HomePod",
            @"AudioAccessory5,1" : @"HomePod mini",
            
            // iPad
            @"iPad1,1" : @"iPad",
            @"iPad2,1" : @"iPad 2",
            @"iPad2,2" : @"iPad 2",
            @"iPad2,3" : @"iPad 2",
            @"iPad2,4" : @"iPad 2",
            @"iPad3,1" : @"iPad (3rd generation)",
            @"iPad3,2" : @"iPad (3rd generation)",
            @"iPad3,3" : @"iPad (3rd generation)",
            @"iPad3,4" : @"iPad (4th generation)",
            @"iPad3,5" : @"iPad (4th generation)",
            @"iPad3,6" : @"iPad (4th generation)",
            @"iPad4,1" : @"iPad Air",
            @"iPad4,2" : @"iPad Air",
            @"iPad4,3" : @"iPad Air",
            @"iPad5,3" : @"iPad Air 2",
            @"iPad5,4" : @"iPad Air 2",
            @"iPad6,7" : @"iPad Pro (12.9-inch)",
            @"iPad6,8" : @"iPad Pro (12.9-inch)",
            @"iPad6,3" : @"iPad Pro (9.7-inch)",
            @"iPad6,4" : @"iPad Pro (9.7-inch)",
            @"iPad6,11" : @"iPad (5th generation)",
            @"iPad6,12" : @"iPad (5th generation)",
            @"iPad7,1" : @"iPad Pro (12.9-inch, 2nd generation)",
            @"iPad7,2" : @"iPad Pro (12.9-inch, 2nd generation)",
            @"iPad7,3" : @"iPad Pro (10.5-inch)",
            @"iPad7,4" : @"iPad Pro (10.5-inch)",
            @"iPad8,1" : @"iPad Pro (11-inch)",
            @"iPad8,2" : @"iPad Pro (11-inch)",
            @"iPad8,3" : @"iPad Pro (11-inch)",
            @"iPad8,4" : @"iPad Pro (11-inch)",
            @"iPad8,5" : @"iPad Pro (12.9-inch, 3nd generation)",
            @"iPad8,6" : @"iPad Pro (12.9-inch, 3nd generation)",
            @"iPad8,7" : @"iPad Pro (12.9-inch, 3nd generation)",
            @"iPad8,8" : @"iPad Pro (12.9-inch, 3nd generation)",
            @"iPad8,9" : @"iPad Pro (11-inch, 2nd generation)",
            @"iPad8,10" : @"iPad Pro (11-inch, 2nd generation)",
            @"iPad8,11" : @"iPad Pro (12.9-inch, 4nd generation)",
            @"iPad8,12" : @"iPad Pro (12.9-inch, 4nd generation)",
            
            // iPad mini
            @"iPad2,5" : @"iPad mini",
            @"iPad2,6" : @"iPad mini",
            @"iPad2,7" : @"iPad mini",
            @"iPad4,4" : @"iPad mini 2",
            @"iPad4,5" : @"iPad mini 2",
            @"iPad4,6" : @"iPad mini 2",
            @"iPad4,7" : @"iPad mini 3",
            @"iPad4,8" : @"iPad mini 3",
            @"iPad4,9" : @"iPad mini 3",
            @"iPad5,1" : @"iPad mini 4",
            @"iPad5,2" : @"iPad mini 4",
            @"iPad11,1" : @"iPad mini 5",
            @"iPad11,2" : @"iPad mini 5",
            
            // iPhone
            @"iPhone1,1" : @"iPhone 1G",
            @"iPhone1,2" : @"iPhone 3G",
            @"iPhone2,1" : @"iPhone 3GS",
            @"iPhone3,1" : @"iPhone 4",
            @"iPhone3,2" : @"iPhone 4",
            @"iPhone4,1" : @"iPhone 4S",
            @"iPhone5,1" : @"iPhone 5",
            @"iPhone5,2" : @"iPhone 5",
            @"iPhone5,3" : @"iPhone 5C",
            @"iPhone5,4" : @"iPhone 5C",
            @"iPhone6,1" : @"iPhone 5S",
            @"iPhone6,2" : @"iPhone 5S",
            @"iPhone7,1" : @"iPhone 6 Plus",
            @"iPhone7,2" : @"iPhone 6",
            @"iPhone8,1" : @"iPhone 6s",
            @"iPhone8,2" : @"iPhone 6s Plus",
            @"iPhone8,4" : @"iPhone SE",
            @"iPhone9,1" : @"iPhone 7",
            @"iPhone9,3" : @"iPhone 7",
            @"iPhone9,2" : @"iPhone 7 Plus",
            @"iPhone9,4" : @"iPhone 7 Plus",
            @"iPhone10,1" : @"iPhone 8",
            @"iPhone10,4" : @"iPhone 8",
            @"iPhone10,2" : @"iPhone 8 Plus",
            @"iPhone10,5" : @"iPhone 8 Plus",
            @"iPhone10,3" : @"iPhone X",
            @"iPhone10,6" : @"iPhone X",
            @"iPhone11,2" : @"iPhone XS",
            @"iPhone11,4" : @"iPhone XS Max",
            @"iPhone11,6" : @"iPhone XS Max",
            @"iPhone11,8" : @"iPhone XR",
            @"iPhone12,1" : @"iPhone 11",
            @"iPhone12,3" : @"iPhone 11 Pro",
            @"iPhone12,5" : @"iPhone 11 Pro Max",
            @"iPhone13,1" : @"iPhone 12 mini",
            @"iPhone13,2" : @"iPhone 12",
            @"iPhone13,3" : @"iPhone 12 Pro",
            @"iPhone13,4" : @"iPhone 12 Pro Max",
            
            // iPod touch
            @"iPod1,1" : @"iPod touch",
            @"iPod2,1" : @"iPod touch (2nd generation)",
            @"iPod3,1" : @"iPod touch (3rd generation)",
            @"iPod4,1" : @"iPod touch (4th generation)",
            @"iPod5,1" : @"iPod touch (5th generation)",
            @"iPod7,1" : @"iPod touch (6th generation)",
            @"iPod9,1" : @"iPod touch (7th generation)",
        };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}

@end
