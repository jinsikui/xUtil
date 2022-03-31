

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface xColor : UIColor

/// 通过rgb值生成颜色0xFFFFFF
+ (UIColor *)fromRGB:(uint)rgbValue;

/// 通过rgb值和透明度生成颜色
+ (UIColor *)fromRGBA:(uint)rgbValue alpha:(CGFloat)alpha;

/// 通过rgb字符串生成颜色#FFFFFF
+ (UIColor *)fromHexStr:(NSString*)hexStr;

/// 通过rgb字符串和透明度生成颜色
+ (UIColor *)fromHexStr:(NSString*)hexStr alpha:(CGFloat)alpha;

/// 通过rgba字符串生成颜色#FFFFFF00
+ (UIColor *)fromRGBAHexStr:(NSString*)rgbaHexStr;

/// 通过argb字符串生成颜色#00FFFFFF
+ (UIColor *)fromARGBHexStr:(NSString*)rgbaHexStr;

/// 通过rgb生成颜色
+ (UIColor *)from8bitR:(Byte)red G:(Byte)green B:(Byte)blue;

/// 通过rgb和透明度生成颜色
+(UIColor *)from8bitR:(Byte)red G:(Byte)green B:(Byte)blue alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
