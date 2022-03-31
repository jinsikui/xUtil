

#import "xUrlHelper.h"
#import "xExtensions.h"

@implementation xUrlHelper

+ (NSString*)urlEncode:(NSString*)input{
    NSMutableCharacterSet *set = [NSMutableCharacterSet whitespaceCharacterSet];
    [set addCharactersInString:@"!*'();:@&=+$/?%#[]"];
    NSString *outputStr = [input stringByAddingPercentEncodingWithAllowedCharacters:set.invertedSet];
    return outputStr;
}

+ (NSString*)urlDecode:(NSString*)input{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByRemovingPercentEncoding];
}

+ (NSString*)queryValueIn:(NSString*)url name:(NSString*)name{
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    NSArray<NSURLQueryItem*> *items = components.queryItems;
    NSURLQueryItem *item = [items x_first:^BOOL(NSURLQueryItem * _Nonnull item) {
        return [item.name isEqualToString:name];
    }];
    if (item) {
        return item.value ?: @"";
    }
    else{
        return nil;
    }
}

+ (NSString*)mergeToInput:(NSString*)input queryParams:(NSDictionary*)params{
    if (params.count == 0 || !input) {
        return input;
    }
    NSURLComponents * components = [NSURLComponents componentsWithString:input];
    NSMutableArray<NSURLQueryItem*> * queryItems = [[NSMutableArray alloc] initWithArray:components.queryItems ?: @[]];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *value = [NSString stringWithFormat:@"%@",obj];
        NSURLQueryItem *item = [queryItems x_first:^BOOL(NSURLQueryItem * _Nonnull item) {
            return [item.name isEqualToString:key];
        }];
        if (item) {
            [queryItems removeObject:item];
        }
        item = [NSURLQueryItem queryItemWithName:key value:value];
        [queryItems addObject:item];
    }];
    components.queryItems = queryItems;
    return components.string;
}

+ (NSString*)hostFor:(NSString*)url{
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    return components.host;
}

+ (NSString*)pathFor:(NSString*)url{
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    return components.path;
}

+ (NSDictionary<NSString*, NSString*>*)paramsFor:(NSString*)url{
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    NSMutableDictionary<NSString*, NSString*> *dic = [NSMutableDictionary new];
    NSArray<NSURLQueryItem*> *items = components.queryItems;
    if (items) {
        [items x_each:^(NSURLQueryItem *item) {
            dic[item.name] = item.value ?: @"";
        }];
    }
    return dic;
}

@end
