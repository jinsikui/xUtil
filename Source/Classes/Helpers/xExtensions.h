

#import <UIKit/UIKit.h>
#if __has_include(<FBLPromises/FBLPromises.h>)
#import <FBLPromises/FBLPromises.h>
#else
#import "FBLPromises.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class CADisplayLink;

typedef void(^xCADisplayLinkExecuteBlock) (CADisplayLink *displayLink);

@interface CADisplayLink (xExtension)

@property (nonatomic,copy)xCADisplayLinkExecuteBlock x_executeBlock;

+ (CADisplayLink *)x_displayLinkWithExecuteBlock:(xCADisplayLinkExecuteBlock)block;

@end

@interface NSObject (xExtension)

@property (nonatomic, assign) BOOL x_initialized;

@property(nonatomic, assign) BOOL x_selected;

/// 创建一个reject状态的promise
/// @param code 错误码
/// @param errorMsg 错误信息
- (FBLPromise*)x_rejectedPromiseWithCode:(NSInteger)code msg:(NSString* __nullable)errorMsg;

/// 创建一个reject状态的promise
/// @param errorMsg 错误信息
- (FBLPromise*)x_rejectedPromise:(NSString * __nullable)errorMsg;

/// 创建一个fufill的promise
/// @param data 传回参数
- (FBLPromise*)x_fulfilledPromise:(id __nullable)data;

/// 创建一个下载图片的promise
/// @param imgUrl 图片url
- (FBLPromise<UIImage*>*)x_downloadImgPromise:(NSString*)imgUrl;

/// 创建一个获取data的promise
/// @param url dataUrl
- (FBLPromise<NSData*>*)x_getDataPromise:(NSString *)url;

/// 创建一个下载图片的promise，若下载成功，fullfil返回downloadFilePath
/// @param url 图片url
/// @param downloadFilePath 存放地址
- (FBLPromise<NSString*>*)x_downloadFilePromise:(NSString*)url downloadFilePath:(NSString*)downloadFilePath;

/// 创建一个延迟执行promise
/// @param queue 执行的队列
/// @param interval 延迟时间
- (FBLPromise*)x_delayPromiseOn:(dispatch_queue_t)queue interval:(NSTimeInterval)interval;

/// 创建一个在主队列延迟执行promise
/// @param interval 延迟时间
- (FBLPromise*)x_delayPromiseOnMainInterval:(NSTimeInterval)interval;

/// 创建一个在全局队列延迟执行promise
/// @param interval 延迟时间
- (FBLPromise*)x_delayPromiseOnGlobalInterval:(NSTimeInterval)interval;

@end

@interface NSData (xExtension)

/// MD5后的字符串
- (NSString*)x_MD5Hex;

/// MD5后base64加密的字符串
- (NSString*)x_MD5Base64;

@end

@interface NSString (xExtension)

/// 获取size（不限宽高）
/// @param font 字体
- (CGSize)x_sizeWithFont:(UIFont*)font;

/// 获取size（限制最大宽度）
/// @param font 字体
/// @param maxWidth 最大宽度
- (CGSize)x_sizeWithFont:(UIFont*)font maxWidth:(CGFloat)maxWidth;

/// 是否以给定字符串开头
/// @param str 字符串
- (BOOL)x_startWith:(NSString *)str;

/// 是否以给定字符串结尾
/// @param str 字符串
- (BOOL)x_endWith:(NSString *)str;

/// CCHmac加密
/// @param key 给定key
- (NSData *)x_hmacSha1ByKey:(NSString *)key;

/// 按字节截取
/// @param ascLen 字节长度
- (NSString* __nonnull)x_shortFormForAscLength:(NSInteger)ascLen;

@end

@interface NSNull (JSON)

@end

@interface UIImage (xExtension)

/// 生成纯色图
/// @param color 颜色
/// @param rect 大小
+ (UIImage *)x_imageWithColor:(UIColor *)color rect:(CGRect)rect;

/// 生成宽为1的纯色图
/// @param color 颜色
/// @param height 高
+ (UIImage *)x_imageWithColor:(UIColor *)color height:(CGFloat)height;

/// 生成宽1高0.5的纯色图
/// @param color 颜色
+ (UIImage *)x_imageWithShadowColor:(UIColor *)color;

/// 缩放图片
/// @param size 大小
- (UIImage *)x_scaleToSize:(CGSize)size;

/// 缩放图片
/// @param scale 当前图片*scale
- (UIImage *)x_scale:(CGFloat)scale;

/// 等比压缩图片
/// @param width 宽度
- (UIImage *)x_compressToWidth:(CGFloat)width;

/// 压缩图片
/// @param size 大小
- (UIImage *)x_compressToSize:(CGSize)size;

@end

@interface UIImageView (xExtension)

/// 以图片名称生成imageView
/// @param imageName 图片名称
+ (UIImageView *)x_imageViewNamed:(NSString *)imageName;

@end

@interface UIView (xExtension)

/// 添加点击手势
/// 会同时设置userInteractionEnabled = true
/// @param block 回调
- (void)x_addTapGestureBlock:(void (^)(id sender))block;

@end


@interface NSAttributedString (xExtension)

/// 根据最大宽计算大小
/// @param maxWidth 最大宽
- (CGSize)x_sizeWithMaxWidth:(CGFloat)maxWidth;

/// 根据最大宽计算高
/// @param maxWidth 最大宽
- (CGFloat)x_heightWithMaxWidth:(CGFloat)maxWidth;

@end

@interface NSMutableAttributedString (xExtension)

/// 添加一个图片
/// @param url 图片url
/// @param size 图片大小
/// @param font 对齐的字体
- (NSMutableAttributedString *)x_appendImgWithUrl:(NSString *)url size:(CGSize)size alignToFont:(UIFont *)font;

/// 添加一个view
/// @param view 要添加的view
/// @param font 对齐的字体
- (NSMutableAttributedString *)x_appendView:(UIView *)view alignToFont:(UIFont *)font;

/// 添加一个图片
/// @param imgName 图片名称
/// @param font 对齐的字体
- (NSMutableAttributedString *)x_appendImgNamed:(NSString *)imgName alignToFont:(UIFont *)font;

/// 添加一个图片
/// @param imgName 图片名称
/// @param size 图片大小
/// @param font 对齐的字体
- (NSMutableAttributedString *)x_appendImgNamed:(NSString *)imgName size:(CGSize)size alignToFont:(UIFont *)font;

/// 添加一个图片
/// @param imgName 图片名称
/// @param scale 图片大小*scale
/// @param font 对齐的字体
- (NSMutableAttributedString *)x_appendImgNamed:(NSString *)imgName scale:(CGFloat)scale alignToFont:(UIFont *)font;

/// 添加一个字符串
/// @param str 字符串
/// @param foreColor 颜色
/// @param font 字体
/// @param underline 是否有下划线
/// @param baselineOffset 与基准线的offset
- (NSMutableAttributedString *)x_appendStr:(NSString *)str foreColor:(UIColor *)foreColor font:(UIFont *)font underline:(BOOL)underline baselineOffset:(CGFloat)baselineOffset;

/// 添加一个字符串
/// @param str 字符串
/// @param foreColor 颜色
/// @param font 字体
- (NSMutableAttributedString *)x_appendStr:(NSString *)str foreColor:(UIColor *)foreColor font:(UIFont *)font;

/// 添加一个字符串
/// @param str 字符串
/// @param foreColor 颜色
/// @param font 字体
+ (NSMutableAttributedString *)x_attrStr:(NSString *)str foreColor:(UIColor *)foreColor font:(UIFont *)font;
@end

@interface UITableView (xExtension)

/// 滑动给定偏移
/// @param offset 偏移点
/// @param animated 是否有动画
- (void)x_scrollToOffset:(CGPoint)offset animated:(BOOL)animated;

/// 滑动到底部
/// @param animated 是否有动画
- (void)x_scrollToBottomAnimated:(BOOL)animated;

@end

@interface UICollectionViewCell (xExtension)

/// 绑定的indexPath
@property(nonatomic, nullable) NSIndexPath *x_indexPath;

/// 绑定的data
@property(nonatomic, nullable) id x_data;

@end

@interface UITableViewCell (xExtension)

/// 绑定的indexPath
@property(nonatomic, nullable) NSIndexPath *x_indexPath;

/// 绑定的data
@property(nonatomic, nullable) id x_data;

@end

@interface UIGestureRecognizer (xExtension)

/// 添加target/action的block
/// @param block 回调
- (void)x_addActionBlock:(void (^)(id sender))block;

/// 删除全部block
- (void)x_removeAllActionBlocks;

@end

@interface NSArray<ObjectType> (xExtension)

/// 安全取值
@property (nonatomic, readonly) ObjectType (^x_safeObjIdx)(NSUInteger index);

/// 过滤
/// @param predicate 条件block
/// @return 满足条件的数组
- (NSArray<__kindof ObjectType> *)x_filter:(BOOL(^)(ObjectType item))predicate;

/// 映射
/// @param selector 处理的block
/// @return 映射后的结果
- (NSArray *)x_map:(id(^)(ObjectType item))selector;


/// 映射，包含index
/// @param selector 处理的block
/// @return 映射后的结果
- (NSArray *)x_mapWithIndex:(id(^)(ObjectType item,NSInteger idx))selector;

/// 找到第一个满足条件的结果
/// @param predicate 条件
/// @return 第一个满足条件的结果，可能为nil
- (nullable ObjectType)x_first:(BOOL(^)(ObjectType item))predicate;

/// 前n个数据，如果当前个数小于n个，那么会返回当前个数
/// @param count n
- (NSMutableArray<ObjectType> *)x_preffixArrayOfCount:(NSInteger)count;

/// 后n个数据，如果当前个数小于n个，那么会返回当前个数
/// @param count n
- (NSMutableArray<ObjectType> *)x_suffixArrayOfCount:(NSInteger)count;


/// 反转
- (NSArray<ObjectType> *)x_reverse;

/// 是否全部满足条件
/// @param predicate 条件
- (BOOL)x_all:(BOOL(^)(ObjectType item))predicate;

/// 是否包含满足条件的数据
/// @param predicate 条件
- (BOOL)x_any:(BOOL(^)(ObjectType item))predicate;

/// 遍历
/// @param action 回调
- (void)x_each:(void(^)(ObjectType item))action;

/// 遍历
/// @param action 回调
- (void)x_eachWithIndex:(void(^)(ObjectType item,NSInteger idx))action;

/// 找到第一个满足条件的index，若无返回NSNotFound
/// @param predicate 条件
- (NSInteger)x_indexOf:(BOOL(^)(ObjectType item))predicate;

@end

#define D_MINUTE        60
#define D_HOUR          3600
#define D_DAY           86400
#define D_WEEK          604800
#define D_YEAR          31556926

@interface NSDate (xExtension)

/// 当前日历
+ (NSCalendar *)x_currentCalendar;

/// 明天
+ (NSDate *)x_dateTomorrow;
/// 昨天
+ (NSDate *)x_dateYesterday;
/// 往后n天
/// @param days n
+ (NSDate *)x_dateWithDaysFromNow:(NSInteger)days;
/// 往前n天
/// @param days n
+ (NSDate *)x_dateWithDaysBeforeNow:(NSInteger)days;
/// 往后n小时
/// @param dHours n
+ (NSDate *)x_dateWithHoursFromNow:(NSInteger)dHours;
/// 往前n小时
/// @param dHours n
+ (NSDate *)x_dateWithHoursBeforeNow:(NSInteger)dHours;
/// 往后n分钟
/// @param dMinutes n
+ (NSDate *)x_dateWithMinutesFromNow:(NSInteger)dMinutes;
/// 往前n分钟
/// @param dMinutes n
+ (NSDate *)x_dateWithMinutesBeforeNow:(NSInteger)dMinutes;

/// 根据format转str
/// @param format 格式
- (NSString*)x_toString:(NSString*)format;

/// 根据style转字符串
/// @param dateStyle 日期style
/// @param timeStyle 时间style
- (NSString *)x_stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (NSString *)x_stringWithFormat:(NSString *)format;

/// date：NSDateFormatterShortStyle
/// time：NSDateFormatterShortStyle
@property (nonatomic, readonly) NSString *x_shortString;
/// date：NSDateFormatterShortStyle
/// time：NSDateFormatterNoStyle
@property (nonatomic, readonly) NSString *x_shortDateString;
/// date：NSDateFormatterNoStyle
/// time：NSDateFormatterShortStyle
@property (nonatomic, readonly) NSString *x_shortTimeString;
/// date：NSDateFormatterMediumStyle
/// time：NSDateFormatterMediumStyle
@property (nonatomic, readonly) NSString *x_mediumString;
/// date：NSDateFormatterMediumStyle
/// time：NSDateFormatterNoStyle
@property (nonatomic, readonly) NSString *x_mediumDateString;
/// date：NSDateFormatterNoStyle
/// time：NSDateFormatterMediumStyle
@property (nonatomic, readonly) NSString *x_mediumTimeString;
/// date：NSDateFormatterLongStyle
/// time：NSDateFormatterLongStyle
@property (nonatomic, readonly) NSString *x_longString;
/// date：NSDateFormatterLongStyle
/// time：NSDateFormatterNoStyle
@property (nonatomic, readonly) NSString *x_longDateString;
/// date：NSDateFormatterNoStyle
/// time：NSDateFormatterLongStyle
@property (nonatomic, readonly) NSString *x_longTimeString;

/// 只比较年月日是否相同
/// @param aDate 日期
- (BOOL)x_isEqualToDateIgnoringTime:(NSDate *)aDate;

/// 今天
- (BOOL)x_isToday;
/// 明天
- (BOOL)x_isTomorrow;
/// 昨天
- (BOOL)x_isYesterday;

/// 同一年前后7天内
/// @param aDate 比较的日期
- (BOOL)x_isSameWeekAsDate:(NSDate *)aDate;
/// 今天前后7天内
- (BOOL)x_isThisWeek;
/// 今天+7天的前后7天内
- (BOOL)x_isNextWeek;
/// 今天-7天的前后7天内
- (BOOL)x_isLastWeek;

/// 同一月
/// @param aDate 比较的日期
- (BOOL)x_isSameMonthAsDate:(NSDate *)aDate;
/// 这月
- (BOOL)x_isThisMonth;
/// 下月
- (BOOL)x_isNextMonth;
/// 上月
- (BOOL)x_isLastMonth;

/// 同一年
/// @param aDate 比较的年份
- (BOOL)x_isSameYearAsDate:(NSDate *)aDate;
/// 今年
- (BOOL)x_isThisYear;
/// 明年
- (BOOL)x_isNextYear;
/// 去年
- (BOOL)x_isLastYear;

/// 是否比给定日期早
/// @param aDate 比较的日期
- (BOOL)x_isEarlierThanDate:(NSDate *)aDate;
/// 是否比给定日期晚
/// @param aDate 比较的日期
- (BOOL)x_isLaterThanDate:(NSDate *)aDate;

/// 是否比当前晚
- (BOOL)x_isInFuture;
/// 是否比当前早
- (BOOL)x_isInPast;


/// 是否周末
- (BOOL)x_isTypicallyWorkday;
/// 是否工作日
- (BOOL)x_isTypicallyWeekend;

/// 加n年
/// @param dYears n
- (NSDate *)x_dateByAddingYears:(NSInteger)dYears;
/// 减n年
/// @param dYears n
- (NSDate *)x_dateBySubtractingYears:(NSInteger)dYears;
/// 加n月
/// @param dMonths n
- (NSDate *)x_dateByAddingMonths:(NSInteger)dMonths;
/// 减n月
/// @param dMonths n
- (NSDate *)x_dateBySubtractingMonths:(NSInteger)dMonths;
/// 加n天
/// @param dDays n
- (NSDate *)x_dateByAddingDays:(NSInteger)dDays;
/// 减n天
/// @param dDays n
- (NSDate *)x_dateBySubtractingDays:(NSInteger)dDays;
/// 加n小时
/// @param dHours n
- (NSDate *)x_dateByAddingHours:(NSInteger)dHours;
/// 减n消失
/// @param dHours n
- (NSDate *)x_dateBySubtractingHours:(NSInteger)dHours;
/// 加n分钟
/// @param dMinutes n
- (NSDate *)x_dateByAddingMinutes:(NSInteger)dMinutes;
/// 减n分钟
/// @param dMinutes n
- (NSDate *)x_dateBySubtractingMinutes:(NSInteger)dMinutes;

/// 时分秒清零
- (NSDate *)x_dateAtStartOfDay;
/// 23时59分59秒
- (NSDate *)x_dateAtEndOfDay;

/// 到北京时间明天凌晨还有多少秒
- (NSTimeInterval)x_timeIntervalToEast8ZoneTomorrow;
/// 比给定日期过了多少分钟
/// @param aDate 日期
- (NSInteger)x_minutesAfterDate:(NSDate *)aDate;
/// 离给定日期还有多少分钟
/// @param aDate 日期
- (NSInteger)x_minutesBeforeDate:(NSDate *)aDate;
/// 比给定日期过了多少小时
/// @param aDate 日期
- (NSInteger)x_hoursAfterDate:(NSDate *)aDate;
/// 离给定日期还有多少小时
/// @param aDate 日期
- (NSInteger)x_hoursBeforeDate:(NSDate *)aDate;
/// 比给定日期过了多少天
/// @param aDate 日期
- (NSInteger)x_daysAfterDate:(NSDate *)aDate;
/// 离给定日期还有多少天
/// @param aDate 日期
- (NSInteger)x_daysBeforeDate:(NSDate *)aDate;
/// 与给定日期差多少天
/// @param anotherDate 日期
- (NSInteger)x_distanceInDaysToDate:(NSDate *)anotherDate;

/// 下一小时
@property (readonly) NSInteger x_nearestHour;
/// 时
@property (readonly) NSInteger x_hour;
/// 分
@property (readonly) NSInteger x_minute;
/// 秒
@property (readonly) NSInteger x_seconds;
/// 日
@property (readonly) NSInteger x_day;
/// 月
@property (readonly) NSInteger x_month;
/// 星期
@property (readonly) NSInteger x_week;
/// 星期几
@property (readonly) NSInteger x_weekday;
/// 第几个星期几
@property (readonly) NSInteger x_nthWeekday; // e.g. 2nd Tuesday of the month == 2
/// 年
@property (readonly) NSInteger x_year;

@end

@interface NSData(xCryptor)

#pragma mark - hmac

/// CCHmac加密MD5算法生成str
/// @param key 给定key
- (NSString *)x_hmacMD5StringWithKey:(NSString *)key;

/// CCHmac加密MD5算法生成data
/// @param key 给定key
- (NSData *)x_hmacMD5DataWithKey:(NSData *)key;

/// CCHmac加密SHA1算法生成str
/// @param key 给定key
- (NSString *)x_hmacSHA1StringWithKey:(NSString *)key;

/// CCHmac加密SHA1算法生成data
/// @param key 给定key
- (NSData *)x_hmacSHA1DataWithKey:(NSData *)key;

/// CCHmac加密SHA224算法生成str
/// @param key 给定key
- (NSString *)x_hmacSHA224StringWithKey:(NSString *)key;

/// CCHmac加密SHA224算法生成data
/// @param key 给定key
- (NSData *)x_hmacSHA224DataWithKey:(NSData *)key;

/// CCHmac加密SHA256算法生成str
/// @param key 给定key
- (NSString *)x_hmacSHA256StringWithKey:(NSString *)key;

/// CCHmac加密SHA256算法生成data
/// @param key 给定key
- (NSData *)x_hmacSHA256DataWithKey:(NSData *)key;

/// CCHmac加密SHA384算法生成str
/// @param key 给定key
- (NSString *)x_hmacSHA384StringWithKey:(NSString *)key;

/// CCHmac加密SHA384算法生成data
/// @param key 给定key
- (NSData *)x_hmacSHA384DataWithKey:(NSData *)key;

/// CCHmac加密SHA512算法生成str
/// @param key 给定key
- (NSString *)x_hmacSHA512StringWithKey:(NSString *)key;

/// CCHmac加密SHA512算法生成data
/// @param key 给定key
- (NSData *)x_hmacSHA512DataWithKey:(NSData *)key;

#pragma mark - RC4

/// rc4解密
/// @param key 给定key
- (NSData *)x_decryptUseRC4WithKey:(NSString *)key;

/// rc4加密
/// @param key 给定key
- (NSData *)x_encryptUseRC4WithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
