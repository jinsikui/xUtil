

#import "xRegex.h"

@interface xRegex()

@property(nonatomic) NSRegularExpression *internalExpression;

@end

@implementation xRegex

- (instancetype)initWithPattern:(NSString*)pattern{
    self = [super init];
    if (self) {
        self.pattern = pattern;
        self.internalExpression = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return self;
}

- (BOOL)test:(NSString*)input{
    if (_internalExpression) {
        NSArray<NSTextCheckingResult *> *results = [_internalExpression matchesInString:input options:0 range:NSMakeRange(0, input.length)];
        return results && results.count > 0;
    }
    else{
        return NO;
    }
}

+ (instancetype)emailRegex{
    static xRegex *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emailPattern = @"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*$";
        instance = [[xRegex alloc] initWithPattern:emailPattern];
    });
    return instance;
}

+ (instancetype)phoneRegex{
    static xRegex *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *phonePattern = @"^1[3|4|5|6|7|8|9][0-9]{9}$";
        instance = [[xRegex alloc] initWithPattern:phonePattern];
    });
    return instance;
}

+ (instancetype)pureNumberRegex{
    static xRegex *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *numPattern = @"^[0-9]*$";
        instance = [[xRegex alloc] initWithPattern:numPattern];
    });
    return instance;
}

+ (instancetype)passwordRegex{
    static xRegex *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *passwordPattern = @"^(?![0-9]+$)(?!([{}()[\\\\]<?!/|>\"~@$&=,.#%'+*\\\\\\-:;^_`]|[A-z])+$)[{}()[\\\\]<?!/|>\"~@$&=,.#%'+*\\\\\\-:;^_`0-9A-z]{8,16}$";
        
        instance = [[xRegex alloc] initWithPattern:passwordPattern];
    });
    return instance;
}
@end
