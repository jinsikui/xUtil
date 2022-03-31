

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface xXCTUserDefineNSCodingObj : NSObject <NSCoding>

@property (nonatomic, copy) NSString *myProp;

- (instancetype)initWithMyProp:(NSString *)myProp;

@end

NS_ASSUME_NONNULL_END
