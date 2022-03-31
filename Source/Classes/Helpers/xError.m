

#import "xError.h"

@implementation xError

+ (instancetype)errorWithCode:(NSInteger)code msg:(NSString*)msg{
    xError *error = [[xError alloc] initWithCode:code msg:msg];
    return error;
}

- (instancetype)initWithCode:(NSInteger)code msg:(NSString*)msg{
    self = [super initWithDomain:X_ERROR_DOMAIN code:code userInfo:nil];
    if (self) {
        _msg = msg;
    }
    return self;
}
@end
