

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xFont : NSObject

/// 中文字体
/// @param size 字号
+ (UIFont *)lightPFWithSize:(CGFloat)size;
/// 中文字体
/// @param size 字号
+ (UIFont *)regularPFWithSize:(CGFloat)size;
/// 中文字体
/// @param size 字号
+ (UIFont *)mediumPFWithSize:(CGFloat)size;
/// 中文字体
/// @param size 字号
+ (UIFont *)semiboldPFWithSize:(CGFloat)size;

/// 英文和数字字体
/// @param size 字号
+ (UIFont *)boldWithSize:(CGFloat)size;
/// 英文和数字字体
/// @param size 字号
+ (UIFont *)regularWithSize:(CGFloat)size;
/// 英文和数字字体
/// @param size 字号
+ (UIFont *)lightWithSize:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END

