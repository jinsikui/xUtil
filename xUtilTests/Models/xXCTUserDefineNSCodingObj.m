

#import "xXCTUserDefineNSCodingObj.h"

@implementation xXCTUserDefineNSCodingObj

- (instancetype)initWithMyProp:(NSString *)myProp {
    if (self = [super init]) {
        self.myProp = myProp;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.myProp forKey:@"myProp"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    NSString *myProp = [coder decodeObjectForKey:@"myProp"];
    return [self initWithMyProp:myProp];
}

- (BOOL)isEqual:(id)object {
    if ([object isMemberOfClass:[xXCTUserDefineNSCodingObj class]]) {
        xXCTUserDefineNSCodingObj *obj = (xXCTUserDefineNSCodingObj *)object;
        if (obj.myProp.length && self.myProp.length) {
            return [self.myProp isEqualToString:obj.myProp];
        } else {
            return obj.myProp.length == self.myProp.length;
        }
    }
    return NO;
}

@end
