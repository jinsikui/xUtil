

#import "xExtensions.h"
#if __has_include(<YYText/YYText.h>)
#import <YYText/YYText.h>
#else
#import "YYText.h"
#endif
#if __has_include(<SDWebImage/UIImageView+WebCache.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#endif
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#else
#import "SDWebImageManager.h"
#endif
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif
#import <objc/runtime.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include <CommonCrypto/CommonCrypto.h>
#import "xError.h"
#import "xFile.h"


@implementation CADisplayLink (xExtension)

- (void)setX_executeBlock:(xCADisplayLinkExecuteBlock)executeBlock{
    objc_setAssociatedObject(self, @selector(x_executeBlock), [executeBlock copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (xCADisplayLinkExecuteBlock)x_executeBlock{
    return objc_getAssociatedObject(self, @selector(x_executeBlock));
}

+ (CADisplayLink *)x_displayLinkWithExecuteBlock:(xCADisplayLinkExecuteBlock)block{
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(x_executeDisplayLink:)];
    displayLink.x_executeBlock = [block copy];
    return displayLink;
}

+ (void)x_executeDisplayLink:(CADisplayLink *)displayLink{
    if (displayLink.x_executeBlock) {
        displayLink.x_executeBlock(displayLink);
    }
}
@end

@implementation NSObject (xExtension)

- (FBLPromise*)x_delayPromiseOn:(dispatch_queue_t)queue interval:(NSTimeInterval)interval {
    FBLPromise *promise = FBLPromise.pendingPromise;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), queue, ^{
        [promise fulfill:nil];
    });
    return promise;
}

- (FBLPromise*)x_delayPromiseOnMainInterval:(NSTimeInterval)interval {
    return [self x_delayPromiseOn:dispatch_get_main_queue() interval:interval];
}

- (FBLPromise*)x_delayPromiseOnGlobalInterval:(NSTimeInterval)interval{
    return [self x_delayPromiseOn:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) interval:interval];
}

- (void)setX_initialized:(BOOL)x_initialized {
    objc_setAssociatedObject(self, @selector(x_initialized), @(x_initialized), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)x_initialized{
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        [self setX_initialized:NO];
        return NO;
    }
    else{
        return [value boolValue];
    }
}

- (void)setX_selected:(BOOL)x_selected {
    objc_setAssociatedObject(self, @selector(x_selected), @(x_selected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)x_selected {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if(!value){
        [self setX_selected:NO];
        return NO;
    }
    else{
        return [value boolValue];
    }
}

- (FBLPromise*)x_rejectedPromiseWithCode:(NSInteger)code msg:(NSString*)errorMsg {
    FBLPromise *promise = FBLPromise.pendingPromise;
    [promise reject:[xError errorWithCode:code msg:errorMsg]];
    return promise;
}

- (FBLPromise*)x_rejectedPromise:(NSString*)errorMsg{
    return [self x_rejectedPromiseWithCode:-1 msg:errorMsg];
}

- (FBLPromise*)x_fulfilledPromise:(id)data{
    FBLPromise *promise = FBLPromise.pendingPromise;
    [promise fulfill:data];
    return promise;
}

- (FBLPromise<UIImage*>*)x_downloadImgPromise:(NSString*)imgUrl {
    return [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imgUrl] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                fulfill(image);
            }
            else{
                reject([xError errorWithCode:-1 msg:@"下载图片失败"]);
            }
        }];
    }];
}

- (FBLPromise<NSString*>*)x_downloadFilePromise:(NSString*)url downloadFilePath:(NSString*)downloadFilePath {
    FBLPromise *promise = FBLPromise.asyncOn(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
        //下载配置文件并保存
        //用downloadTask
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURL *URL = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            //原始json文件保存地址
            return [NSURL fileURLWithPath:downloadFilePath];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                reject(error);
            } else {
                fulfill(downloadFilePath);
            }
        }];
        [downloadTask resume];
    });
    return promise;
}

- (FBLPromise<NSData*>*)x_getDataPromise:(NSString *)url {
    FBLPromise *promise = FBLPromise.asyncOn(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        //解析出responseObject为NSData
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSURL *URL = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else {
                fulfill(responseObject);
            }
        }];
        [dataTask resume];
    });
    return promise;
}

@end


@implementation NSData (xExtension)

- (NSString *)x_MD5Hex {
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return output;
}

- (NSString *)x_MD5Base64 {
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
    NSData *data = [NSData dataWithBytes:md5Buffer length:CC_MD5_DIGEST_LENGTH];
    return [xFile dataToBase64:data];
}

@end

@implementation NSString (xExtension)

- (NSString*)stringValue{
    return self;
}

- (CGSize)x_sizeWithFont:(UIFont*)font{
    CGSize size = [self x_sizeWithFont:font maxWidth:CGFLOAT_MAX];
    return CGSizeMake(size.width + 1, size.height);
}

- (CGSize)x_sizeWithFont:(UIFont*)font maxWidth:(CGFloat)maxWidth{
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName: font}];
    CGSize size = [attr boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

- (BOOL)x_startWith:(NSString*)str{
    NSRange range = [self rangeOfString:str options:NSLiteralSearch];
    return range.location == 0;
}

- (BOOL)x_endWith:(NSString*)str{
    NSRange range = [self rangeOfString:str options:NSLiteralSearch | NSBackwardsSearch];
    return range.location == self.length - str.length;
}

- (NSData *)x_hmacSha1ByKey:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return HMAC;
}

- (NSString * __nonnull)x_shortFormForAscLength:(NSInteger)ascLen {
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar uc = [self characterAtIndex:i];
        asciiLength += isascii(uc) ? 1 : 2;
        if (asciiLength > ascLen) {
            NSString * substring = [NSString stringWithFormat:@"%@...", [self substringToIndex:i]];
            return substring;
        }
    }
    return [self copy];
}

@end

@implementation NSNull (JSON)

- (void)forwardInvocation:(NSInvocation *)invocation{
    if ([self respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:self];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    NSMethodSignature *signature = [[NSNull class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        signature = [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
    }
    return signature;
}

- (NSUInteger)count{
    return 0;
}

- (NSUInteger)length{
    return 0;
}

- (NSUInteger)unsignedIntegerValue{
    return 0;
}

- (NSInteger)integerValue{
    return 0;
}

- (int)intValue{
    return 0;
}

- (float)floatValue{
    return 0;
}

- (NSString *)stringValue{
    return @"";
}

- (NSString *)description{
    return @"";
}

- (NSArray *)componentsSeparatedByString:(NSString *)separator{
    return @[];
}

- (id)objectForKey:(id)key{
    return nil;
}

- (id)objectAtIndex:(NSUInteger)index{
    return nil;
}

- (BOOL)boolValue{
    return NO;
}

@end

@implementation UIView (xExtension)

- (void)x_addTapGestureBlock:(void (^)(id sender))block{
    UITapGestureRecognizer *g = [UITapGestureRecognizer new];
    [g x_addActionBlock:block];
    [self addGestureRecognizer:g];
    self.userInteractionEnabled = true;
}

@end

@implementation UIImage (xExtension)

+ (UIImage *)x_imageWithColor:(UIColor *)color rect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)x_imageWithColor:(UIColor *)color height:(CGFloat)height {
    return [self x_imageWithColor:color rect:CGRectMake(0, 0, 1, height)];
}

+ (UIImage*)x_imageWithShadowColor:(UIColor*)color{
    return [self x_imageWithColor:color rect:CGRectMake(0, 0, 1, 0.5)];
}

- (UIImage *)x_scaleToSize:(CGSize)size {
    CGRect rect = CGRectMake(0,0,size.width,size.height);
    UIGraphicsBeginImageContext( rect.size );
    [self drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img = [UIImage imageWithData:imageData];
    return img;
}

- (UIImage*)x_scale:(CGFloat)scale{
    CGSize size = CGSizeMake(self.size.width*scale, self.size.height*scale);
    return [self x_scaleToSize:size];
}

- (BOOL)x_isOpaque{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return !(alphaInfo == kCGImageAlphaFirst ||
             alphaInfo == kCGImageAlphaLast ||
             alphaInfo == kCGImageAlphaPremultipliedFirst ||
             alphaInfo == kCGImageAlphaNoneSkipLast);
}

- (UIImage*)x_compressToWidth:(CGFloat)width{
    if (self.size.width <= width) {
        return self;
    }
    CGFloat height = (self.size.height / self.size.width) * width;
    return [self x_compressToSize:CGSizeMake(width, height)];
}

- (UIImage*)x_compressToSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0, 0);
    if (!CGSizeEqualToSize(imageSize, size))//!imageSize.equalTo(size))
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContextWithOptions(size, self.x_isOpaque, self.scale); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [self drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@implementation UIImageView (xExtension)

+ (UIImageView*)x_imageViewNamed:(NSString*)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    return [[UIImageView alloc] initWithImage:image];
}

@end

@implementation NSAttributedString (xExtension)

- (CGSize)x_sizeWithMaxWidth:(CGFloat)maxWidth{
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(maxWidth, CGFLOAT_MAX) text:self];
    return layout.textBoundingSize;
}

- (CGFloat)x_heightWithMaxWidth:(CGFloat)maxWidth{
    CGSize size = [self x_sizeWithMaxWidth:maxWidth];
    return size.height;
}

@end

@implementation NSMutableAttributedString (xExtension)

- (NSMutableAttributedString*)x_appendImgWithUrl:(NSString*)url size:(CGSize)size alignToFont:(UIFont*)font{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect f = imageView.frame;
    f.size = size;
    imageView.frame = f;
    [imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    NSMutableAttributedString *imgAttr = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [self appendAttributedString:imgAttr];
    return self;
}

- (NSMutableAttributedString*)x_appendView:(UIView*)view alignToFont:(UIFont*)font{
    NSMutableAttributedString *attr = [NSMutableAttributedString yy_attachmentStringWithContent:view contentMode:UIViewContentModeCenter attachmentSize:view.bounds.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [self appendAttributedString:attr];
    return self;
}

- (NSMutableAttributedString*)x_appendImgNamed:(NSString*)imgName alignToFont:(UIFont*)font{
    UIImage *img = [UIImage imageNamed:imgName];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = img;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect f = imageView.frame;
    f.size = img.size;
    imageView.frame = f;
    NSMutableAttributedString *imgAttr = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:img.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [self appendAttributedString:imgAttr];
    return self;
}

- (NSMutableAttributedString*)x_appendImgNamed:(NSString*)imgName size:(CGSize)size alignToFont:(UIFont*)font{
    UIImage *img = [UIImage imageNamed:imgName];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = img;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect f = imageView.frame;
    f.size = size;
    imageView.frame = f;
    NSMutableAttributedString *imgAttr = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:img.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [self appendAttributedString:imgAttr];
    return self;
}

- (NSMutableAttributedString*)x_appendImgNamed:(NSString*)imgName scale:(CGFloat)scale alignToFont:(UIFont*)font{
    UIImage *img = [UIImage imageNamed:imgName];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = img;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect f = imageView.frame;
    f.size = CGSizeMake(img.size.width*scale,img.size.height*scale);
    imageView.frame = f;
    NSMutableAttributedString *imgAttr = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:img.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    [self appendAttributedString:imgAttr];
    return self;
}

- (NSMutableAttributedString*)x_appendStr:(NSString*)str foreColor:(UIColor*)foreColor font:(UIFont*)font underline:(BOOL)underline baselineOffset:(CGFloat)baselineOffset{
    
    NSMutableDictionary<NSAttributedStringKey, id> *attributes = [[NSMutableDictionary alloc] initWithDictionary:
                                                                  @{ NSForegroundColorAttributeName: foreColor,
                                                                     NSFontAttributeName: font }];
    if (underline) {
        attributes[NSUnderlineStyleAttributeName] = @(1);
    }
    if (baselineOffset != 0) {
        attributes[NSBaselineOffsetAttributeName] = @(baselineOffset);
    }
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:str attributes:attributes];
    [self appendAttributedString:attr];
    return self;
}

- (NSMutableAttributedString*)x_appendStr:(NSString*)str foreColor:(UIColor*)foreColor font:(UIFont*)font{
    return [self x_appendStr:str foreColor:foreColor font:font underline:NO baselineOffset:0];
}

+ (NSMutableAttributedString*)x_attrStr:(NSString*)str foreColor:(UIColor*)foreColor font:(UIFont*)font{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str attributes:
                                       @{NSForegroundColorAttributeName: foreColor,
                                         NSFontAttributeName: font}];
    return attr;
}
@end

@implementation UITableView (xExtension)

- (void)x_scrollToOffset:(CGPoint)offset animated:(BOOL)animated {
    [self setContentOffset:offset animated:animated];
}

- (void)x_scrollToBottomAnimated:(BOOL)animated{
    long rowCount = [self numberOfRowsInSection:0];
    if (rowCount > 0) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
@end

@implementation UICollectionViewCell (xExtension)

- (NSIndexPath*)x_indexPath{
    NSIndexPath *indexPath = objc_getAssociatedObject(self, _cmd);
    return indexPath;
}

- (void)setX_indexPath:(NSIndexPath *)x_indexPath{
    objc_setAssociatedObject(self, @selector(x_indexPath), x_indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)x_data{
    id data = objc_getAssociatedObject(self, _cmd);
    return data;
}

- (void)setX_data:(id)x_data{
    objc_setAssociatedObject(self, @selector(x_data), x_data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UITableViewCell (xExtension)

- (NSIndexPath*)x_indexPath{
    NSIndexPath *indexPath = objc_getAssociatedObject(self, _cmd);
    return indexPath;
}

- (void)setX_indexPath:(NSIndexPath *)x_indexPath{
    objc_setAssociatedObject(self, @selector(x_indexPath), x_indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)x_data{
    id data = objc_getAssociatedObject(self, _cmd);
    return data;
}

- (void)setX_data:(id)x_data{
    objc_setAssociatedObject(self, @selector(x_data), x_data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface _xUIGestureRecognizerBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _xUIGestureRecognizerBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}
@end

static const int block_key;

@implementation UIGestureRecognizer (xExtension)

- (void)x_addActionBlock:(void (^)(id sender))block {
    _xUIGestureRecognizerBlockTarget *target = [[_xUIGestureRecognizerBlockTarget alloc] initWithBlock:block];
    [self addTarget:target action:@selector(invoke:)];
    NSMutableArray *targets = [self _x_allUIGestureRecognizerBlockTargets];
    [targets addObject:target];
}

- (void)x_removeAllActionBlocks{
    NSMutableArray *targets = [self _x_allUIGestureRecognizerBlockTargets];
    [targets enumerateObjectsUsingBlock:^(id target, NSUInteger idx, BOOL *stop) {
        [self removeTarget:target action:@selector(invoke:)];
    }];
    [targets removeAllObjects];
}

- (NSMutableArray *)_x_allUIGestureRecognizerBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end

@implementation NSArray (xExtension)

- (id (^)(NSUInteger))x_safeObjIdx {
    __weak typeof(self) weakSelf = self;
    id (^block)(NSUInteger index) = ^(NSUInteger index) {
        return (weakSelf.count-1)<index ? nil : weakSelf[index];
    };
    return block;
}

- (NSArray *)x_filter:(BOOL (^)(id))predicate {
    if (!predicate) return self;
    NSMutableArray *result = [NSMutableArray array];
    for (id item in self) {
        if (predicate(item)) {
            [result addObject:item];
        }
    }
    return result;
}

- (NSArray *)x_map:(id (^)(id))selector {
    if (!selector) return self;
    // Capacity:avoid size change.
    NSMutableArray *result =[NSMutableArray arrayWithCapacity:self.count];
    for (id item in self) {
        id mapResult = selector(item);
        if (mapResult) [result addObject:mapResult];
    }
    return result;
}

- (NSArray *)x_mapWithIndex:(id (^)(id, NSInteger))selector {
    if (!selector) return self;
    // Capacity:avoid size change.
    NSMutableArray *result =[NSMutableArray arrayWithCapacity:self.count];
    for (int i = 0; i < self.count; i++) {
        id mapResult = selector([self objectAtIndex:i],i);
        if (mapResult) [result addObject:mapResult];
    }
    return result;
}

- (NSMutableArray *)x_preffixArrayOfCount:(NSInteger)count{
    if (count < 0) {
        return nil;
    }
    NSMutableArray *result =[NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count && i < self.count; i++) {
        [result addObject:[self objectAtIndex:i]];
    }
    return result;
}

- (NSMutableArray *)x_suffixArrayOfCount:(NSInteger)count{
    if (count < 0) {
        return nil;
    }
    NSMutableArray *result =[NSMutableArray arrayWithCapacity:count];
    long i = self.count - count;
    i = i < 0 ? 0 : i;
    for (; i < self.count; i++) {
        [result addObject:[self objectAtIndex:i]];
    }
    return result;
}

- (id)x_first:(BOOL (^)(id))predicate {
    if (!predicate) return self.firstObject;
    for (id item in self) {
        if (predicate(item)) {
            return item;
        }
    }
    return nil;
}

- (NSArray *)x_reverse {
    return [self reverseObjectEnumerator].allObjects;
}

- (BOOL)x_all:(BOOL (^)(id))predicate {
    if (!predicate) return NO;
    for (id item in self) {
        if (!predicate(item)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)x_any:(BOOL (^)(id))predicate {
    if (!predicate) return NO;
    for (id item in self) {
        if (predicate(item)) {
            return YES;
        }
    }
    return NO;
}

- (void)x_each:(void (^)(id))action {
    if (!action) return;
    for (id item in self) {
        action(item);
    }
}

- (void)x_eachWithIndex:(void (^)(id, NSInteger))action {
    if (!action) return;
    for (int i = 0; i < self.count; i++) {
        id item = [self objectAtIndex:i];
        action(item,i);
    }
}

- (NSInteger)x_indexOf:(BOOL (^)(id))predicate {
    if (!predicate) return NSNotFound;
    for (NSInteger i = 0; i < self.count; i++) {
        id item = self[i];
        if (predicate(item)) return i;
    }
    return NSNotFound;
}

@end

static const unsigned componentFlags = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

@implementation NSDate (xExtension)

+ (NSCalendar *)x_currentCalendar {
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

#pragma mark - Relative Dates

+ (NSDate *)x_dateWithDaysFromNow:(NSInteger)days {
    // Thanks, Jim Morrison
    return [[NSDate date] x_dateByAddingDays:days];
}

+ (NSDate *)x_dateWithDaysBeforeNow:(NSInteger)days {
    // Thanks, Jim Morrison
    return [[NSDate date] x_dateBySubtractingDays:days];
}

+ (NSDate *)x_dateTomorrow {
    return [NSDate x_dateWithDaysFromNow:1];
}

+ (NSDate *)x_dateYesterday {
    return [NSDate x_dateWithDaysBeforeNow:1];
}

+ (NSDate *)x_dateWithHoursFromNow:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)x_dateWithHoursBeforeNow:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)x_dateWithMinutesFromNow:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *)x_dateWithMinutesBeforeNow:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSString*)x_toString:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

#pragma mark - String Properties

- (NSString *)x_stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *)x_stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

- (NSString *)x_shortString {
    return [self x_stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)x_shortTimeString {
    return [self x_stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)x_shortDateString {
    return [self x_stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)x_mediumString {
    return [self x_stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *)x_mediumTimeString {
    return [self x_stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *)x_mediumDateString {
    return [self x_stringWithDateStyle:NSDateFormatterMediumStyle  timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)x_longString {
    return [self x_stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *)x_longTimeString {
    return [self x_stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *)x_longDateString {
    return [self x_stringWithDateStyle:NSDateFormatterLongStyle  timeStyle:NSDateFormatterNoStyle];
}

#pragma mark - Comparing Dates

- (BOOL)x_isEqualToDateIgnoringTime:(NSDate *)aDate {
    NSDateComponents *components1 = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate x_currentCalendar] components:componentFlags fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL)x_isToday {
    return [self x_isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)x_isTomorrow {
    return [self x_isEqualToDateIgnoringTime:[NSDate x_dateTomorrow]];
}

- (BOOL)x_isYesterday {
    return [self x_isEqualToDateIgnoringTime:[NSDate x_dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL)x_isSameWeekAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    NSDateComponents *components2 = [[NSDate x_currentCalendar] components:componentFlags fromDate:aDate];
    
    // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
    if (components1.weekOfYear != components2.weekOfYear) return NO;
    
    // Must have a time interval under 1 week. Thanks @aclark
    return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL)x_isThisWeek {
    return [self x_isSameWeekAsDate:[NSDate date]];
}

- (BOOL)x_isNextWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self x_isSameWeekAsDate:newDate];
}

- (BOOL)x_isLastWeek {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return [self x_isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL)x_isSameMonthAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL)x_isThisMonth {
    return [self x_isSameMonthAsDate:[NSDate date]];
}

// Thanks Marcin Krzyzanowski, also for adding/subtracting years and months
- (BOOL)x_isLastMonth {
    return [self x_isSameMonthAsDate:[[NSDate date] x_dateBySubtractingMonths:1]];
}

- (BOOL)x_isNextMonth {
    return [self x_isSameMonthAsDate:[[NSDate date] x_dateByAddingMonths:1]];
}

- (BOOL)x_isSameYearAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

- (BOOL)x_isThisYear {
    // Thanks, baspellis
    return [self x_isSameYearAsDate:[NSDate date]];
}

- (BOOL)x_isNextYear {
    NSDateComponents *components1 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year + 1));
}

- (BOOL)x_isLastYear {
    NSDateComponents *components1 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate x_currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    
    return (components1.year == (components2.year - 1));
}

- (BOOL)x_isEarlierThanDate:(NSDate *)aDate {
    return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)x_isLaterThanDate:(NSDate *)aDate {
    return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL)x_isInFuture {
    return ([self x_isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL)x_isInPast {
    return ([self x_isEarlierThanDate:[NSDate date]]);
}


#pragma mark - Roles
- (BOOL)x_isTypicallyWeekend {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL)x_isTypicallyWorkday {
    return ![self x_isTypicallyWeekend];
}

#pragma mark - Adjusting Dates

// Thaks, rsjohnson
- (NSDate *)x_dateByAddingYears:(NSInteger)dYears {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)x_dateBySubtractingYears:(NSInteger)dYears {
    return [self x_dateByAddingYears:-dYears];
}

- (NSDate *)x_dateByAddingMonths:(NSInteger)dMonths {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)x_dateBySubtractingMonths:(NSInteger)dMonths {
    return [self x_dateByAddingMonths:-dMonths];
}

// Courtesy of dedan who mentions issues with Daylight Savings
- (NSDate *)x_dateByAddingDays:(NSInteger)dDays {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dDays];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *)x_dateBySubtractingDays:(NSInteger)dDays {
    return [self x_dateByAddingDays:(dDays * -1)];
}

- (NSDate *)x_dateByAddingHours:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)x_dateBySubtractingHours:(NSInteger)dHours {
    return [self x_dateByAddingHours:(dHours * -1)];
}

- (NSDate *)x_dateByAddingMinutes:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *)x_dateBySubtractingMinutes:(NSInteger)dMinutes {
    return [self x_dateByAddingMinutes:(dMinutes * -1)];
}

- (NSDateComponents *)x_componentsWithOffsetFromDate:(NSDate *)aDate {
    NSDateComponents *dTime = [[NSDate x_currentCalendar] components:componentFlags fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark - Extremes

- (NSDate *)x_dateAtStartOfDay {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate x_currentCalendar] dateFromComponents:components];
}

// Thanks gsempe & mteece
- (NSDate *)x_dateAtEndOfDay {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    components.hour = 23; // Thanks Aleksey Kononov
    components.minute = 59;
    components.second = 59;
    return [[NSDate x_currentCalendar] dateFromComponents:components];
}

#pragma mark - Retrieving Intervals

- (NSTimeInterval)x_timeIntervalToEast8ZoneTomorrow{
    //获取当前时间到北京时间第二天早上还有多少时间
    NSDate *date = [NSDate date];
    //东8区和systmeZone的时差
    NSTimeZone *systmeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval delta = 8 * 60 * 60 - systmeZone.secondsFromGMT;
    date = [NSDate dateWithTimeInterval:delta sinceDate:date];
    NSDate *tomorrowStart = [[date x_dateByAddingDays:1] x_dateAtStartOfDay];
    NSTimeInterval interval = [tomorrowStart timeIntervalSinceDate:date];
    return interval;
}

- (NSInteger)x_minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)x_minutesBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)x_hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)x_hoursBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)x_daysAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger)x_daysBeforeDate:(NSDate *)aDate {
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)x_distanceInDaysToDate:(NSDate *)anotherDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark - Decomposing Dates

- (NSInteger)x_nearestHour {
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [[NSDate x_currentCalendar] components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}

- (NSInteger)x_hour {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.hour;
}

- (NSInteger)x_minute {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.minute;
}

- (NSInteger)x_seconds {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.second;
}

- (NSInteger)x_day {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.day;
}

- (NSInteger)x_month {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.month;
}

- (NSInteger)x_week {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.weekOfYear;
}

- (NSInteger)x_weekday {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.weekday;
}

- (NSInteger)x_nthWeekday {
    // e.g. 2nd Tuesday of the month is 2
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger)x_year {
    NSDateComponents *components = [[NSDate x_currentCalendar] components:componentFlags fromDate:self];
    return components.year;
}
@end

@implementation NSData(xCryptor)

#pragma mark - hmac

- (NSString *)x_hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key {
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    unsigned char result[size];
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    CCHmac(alg, cKey, strlen(cKey), self.bytes, self.length, result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:size * 2];
    for (int i = 0; i < size; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

- (NSData *)x_hmacDataUsingAlg:(CCHmacAlgorithm)alg withKey:(NSData *)key {
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    unsigned char result[size];
    CCHmac(alg, [key bytes], key.length, self.bytes, self.length, result);
    return [NSData dataWithBytes:result length:size];
}

- (NSString *)x_hmacMD5StringWithKey:(NSString *)key {
    return [self x_hmacStringUsingAlg:kCCHmacAlgMD5 withKey:key];
}

- (NSData *)x_hmacMD5DataWithKey:(NSData *)key {
    return [self x_hmacDataUsingAlg:kCCHmacAlgMD5 withKey:key];
}

- (NSString *)x_hmacSHA1StringWithKey:(NSString *)key {
    return [self x_hmacStringUsingAlg:kCCHmacAlgSHA1 withKey:key];
}

- (NSData *)x_hmacSHA1DataWithKey:(NSData *)key {
    return [self x_hmacDataUsingAlg:kCCHmacAlgSHA1 withKey:key];
}

- (NSString *)x_hmacSHA224StringWithKey:(NSString *)key {
    return [self x_hmacStringUsingAlg:kCCHmacAlgSHA224 withKey:key];
}

- (NSData *)x_hmacSHA224DataWithKey:(NSData *)key {
    return [self x_hmacDataUsingAlg:kCCHmacAlgSHA224 withKey:key];
}

- (NSString *)x_hmacSHA256StringWithKey:(NSString *)key {
    return [self x_hmacStringUsingAlg:kCCHmacAlgSHA256 withKey:key];
}

- (NSData *)x_hmacSHA256DataWithKey:(NSData *)key {
    return [self x_hmacDataUsingAlg:kCCHmacAlgSHA256 withKey:key];
}

- (NSString *)x_hmacSHA384StringWithKey:(NSString *)key {
    return [self x_hmacStringUsingAlg:kCCHmacAlgSHA384 withKey:key];
}

- (NSData *)x_hmacSHA384DataWithKey:(NSData *)key {
    return [self x_hmacDataUsingAlg:kCCHmacAlgSHA384 withKey:key];
}

- (NSString *)x_hmacSHA512StringWithKey:(NSString *)key {
    return [self x_hmacStringUsingAlg:kCCHmacAlgSHA512 withKey:key];
}

- (NSData *)x_hmacSHA512DataWithKey:(NSData *)key {
    return [self x_hmacDataUsingAlg:kCCHmacAlgSHA512 withKey:key];
}

#pragma mark - RC4

- (NSData *)x_decryptUseRC4WithKey:(NSString *)key {
    return [self x_encryptUseRC4WithKey:key];
}

- (NSData *)x_encryptUseRC4WithKey:(NSString *)key {
    UInt8  iK[256];
    UInt8  iS[256];
    int i;
    for (i = 0; i < 256; ++i) {
        iS[i] = i;
        iK[i] = (UInt8)[key characterAtIndex: (i % key.length)];
    }
    int j = 0;
    for (i = 0; i < 256; ++i) {
        int is = iS[i];
        int ik = iK[i];
        j = (j + is + ik) % 256;
        UInt8 temp = iS[i];
        iS[i] = iS[j];
        iS[j] = temp;
    }
    
    i = 0;
    j = 0;
    NSMutableData *result = [[NSMutableData alloc] initWithCapacity:self.length];
    for (int x = 0; x < [self length]; ++x) {
        i = (i + 1) % 256;
        int is_i = iS[i];
        j = (j + is_i) % 256;
        
        int temp = iS[i];
        iS[i] = iS[j];
        iS[j] = temp;
        
        is_i = iS[i];
        int is_j = iS[j];
        int k = iS [(is_i + is_j) % 256];
        
        UInt8 ch;
        [self getBytes:&ch range:NSMakeRange(x, 1)];
        UInt8 ch_y = ch ^ k;
        [result appendBytes:&ch_y length:1];
    }
    return result;
}

@end
