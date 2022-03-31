//

#import "xHooker.h"

#import <objc/runtime.h>

@implementation xHooker

+ (void)exchangeOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL mclass:(Class)mclass{
    Method originalMethod = class_getInstanceMethod(mclass, originSEL);
    Method newMethod = class_getInstanceMethod(mclass, newSEL);
    
    BOOL ret = class_addMethod(mclass,originSEL,
                    method_getImplementation(newMethod),
                    method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(mclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)exchangeClassOriginMethod:(SEL)originSEL newMethod:(SEL)newSEL
                           mclass:(Class)mclass{
    Class bclass = object_getClass(mclass);
    
    Method originalMethod = class_getClassMethod(bclass, originSEL);
    Method newMethod = class_getClassMethod(bclass, newSEL);
    
    BOOL ret = class_addMethod(bclass,originSEL,
                               method_getImplementation(newMethod),
                               method_getTypeEncoding(newMethod));
    
    if (ret) {
        class_replaceMethod(bclass,originSEL,
                            method_getImplementation(newMethod),
                            method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
