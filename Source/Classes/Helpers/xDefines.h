


#ifndef xDefines_h
#define xDefines_h

#define kScreenWidth       ([xDevice screenWidth])
#define kScreenHeight      ([xDevice screenHeight])
#define kStatusBarHeight   ([xDevice statusBarHeight])
#define kNavBarHeight      ([xDevice navBarHeight])
#define kContentWidth      (kScreenWidth)
#define kContentHeight     (kScreenHeight - kStatusBarHeight - kNavBarHeight)

#define V_IOS_8 (([xDevice iosVersion]>=8.0)?YES:NO)
#define V_IOS_9 (([xDevice iosVersion]>=9.0)?YES:NO)
#define V_IOS_10 (([xDevice iosVersion]>=10.0)?YES:NO)
#define V_IOS_11 (([xDevice iosVersion]>=11.0)?YES:NO)

#define kColor(x)           ([xColor fromRGB:x])
#define kColorA(x,a)         ([xColor fromRGBA:x alpha:a])

//#ifdef DEBUG
//#   define NSLog(...) NSLog(__VA_ARGS__)
//#else
//#   define NSLog(...) (void)0
//#endif

/*!
 *  @brief 英文和数字字体
 */
#define kFontBold(x)        ([xFont boldWithSize:x])
#define kFontRegular(x)     ([xFont regularWithSize:x])
#define kFontLight(x)       ([xFont lightWithSize:x])
/*!
 *  @brief 中文字体
 */
#define kFontPF(x)          ([xFont lightPFWithSize:x])
#define kFontRegularPF(x)   ([xFont regularPFWithSize:x])
#define kFontMediumPF(x)    ([xFont mediumPFWithSize:x])
#define kFontSemiboldPF(x)  ([xFont semiboldPFWithSize:x])

#define x_not_null(x) (x != nil && ![x isKindOfClass:[NSNull class]])
#define x_is_null(x) (x == nil || [x isKindOfClass:[NSNull class]])

#define x_arr_null(x) (x == nil || ![x isKindOfClass:[NSArray class]] || ((NSArray*)x).count == 0)
#define x_arr_not_null(x) (x && [x isKindOfClass:[NSArray class]] && ((NSArray*)x).count > 0)
#define x_nonnull_arr(x) (x_arr_not_null(x) ? x : @[])

#define x_str_null(x) (x == nil || ![x isKindOfClass:[NSString class]] || ((NSString*)x).length == 0)
#define x_str_not_null(x) (x && [x isKindOfClass:[NSString class]] && ((NSString*)x).length > 0)
#define x_nonnull_str(x) (x_str_not_null(x) ? x : @"")

#define x_dict_null(x) (x == nil || ![x isKindOfClass:[NSDictionary class]] || ((NSDictionary*)x).allKeys.count == 0)
#define x_dict_not_null(x) (x && [x isKindOfClass:[NSDictionary class]] && ((NSDictionary*)x).allKeys.count > 0)
#define x_nonnull_dict(x) (x_dict_not_null(x) ? x : @{})

#define x_int_null(x) (x == nil || ![x isKindOfClass:[NSNumber class]] || ([x intValue] == 0))
#define x_int_not_null(x) (x && [x isKindOfClass:[NSNumber class]] && ([x intValue] != 0))

#define x_long_null(x) (x == nil || ![x isKindOfClass:[NSNumber class]] || ([x longValue] == 0))
#define x_long_not_null(x) (x && [x isKindOfClass:[NSNumber class]] && ([x longValue] != 0))

#endif
