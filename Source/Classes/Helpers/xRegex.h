

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface xRegex : NSObject

/// 当前正则表达式
@property (nonatomic) NSString *pattern;

/// 用给定正则生成实例
/// @param pattern 正则表达式
- (instancetype)initWithPattern:(NSString*)pattern;

/// 输入是否满足当前正则表达式
/// @param input 输入
- (BOOL)test:(NSString *)input;

/// email
+ (instancetype)emailRegex;

/// 电话号码
+ (instancetype)phoneRegex;

/// 8-16位字母加数字
+ (instancetype)passwordRegex;

/// 纯数字
+ (instancetype)pureNumberRegex;

@end

NS_ASSUME_NONNULL_END
