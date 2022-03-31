

#import "xKeychainStore.h"

#import "xFile.h"
#import "xDefines.h"

#define xKEYCHAINSTORE_DEFAULT_NAME @"xKeychainStore-default"

@interface xKeychainStore()

@property(nonatomic,copy) NSString *name;

@end

@implementation xKeychainStore

+(instancetype)defaultStore{
    return [self storeWithName:xKEYCHAINSTORE_DEFAULT_NAME];
}

+(instancetype)storeWithName:(NSString *)name{
    return [[xKeychainStore alloc] initWithName:name];
}

-(instancetype)initWithName:(NSString*)name{
    self = [super init];
    if(self){
        _name = name;
    }
    return self;
}

-(id _Nullable)objectForKeyedSubscript:(NSString*)key{
    NSMutableDictionary * query = [[NSMutableDictionary alloc]init];
    [query setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [query setValue:key forKey:(id)kSecAttrAccount];
    [query setValue:self.name forKey:(id)kSecAttrService];
    [query setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    OSStatus err   = noErr;
    CFTypeRef rv = nil; // keychain的返回值
    err = SecItemCopyMatching((__bridge CFDictionaryRef)query, &rv);
    if (err == errSecSuccess) {
        NSData * data = [NSData dataWithData:(__bridge NSData *)rv];
        !rv?:CFRelease(rv);
        id obj =[NSKeyedUnarchiver unarchiveObjectWithData:data];
        return obj;
    }else{
        return nil;
    }
}

-(void)setObject:(id<NSCoding> _Nullable)obj forKeyedSubscript:(NSString *)key{
    BOOL notValidObject = (obj && ![xFile verifyArchivable:obj]);
    if (notValidObject) {
        NSLog(@"[xKeychainStore] %@ failed : %@ -> %@", NSStringFromSelector(_cmd), key, obj);
        return;
    }
    
    NSMutableDictionary * query = [[NSMutableDictionary alloc]init];
    [query setValue:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    [query setValue:key forKey:(id)kSecAttrAccount];
    [query setValue:self.name forKey:(id)kSecAttrService];
    [query setValue:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    OSStatus err   = noErr;
    CFTypeRef rv = nil; // keychain的返回值
    err = SecItemCopyMatching((__bridge CFDictionaryRef)query, &rv);
    if (err == errSecSuccess) {
        if (obj) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
            [query removeObjectForKey:(id)kSecReturnData];
            NSDictionary * attrs = @{(id)kSecValueData:data};
            err = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attrs);
            if (err != errSecSuccess) {
                [query removeObjectForKey:(id)kSecMatchLimit];
                [query removeObjectForKey:(id)kSecValueData];
                [query setValue:data forKey:(id)kSecValueData];
                err = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
            }
        }else{
            err = SecItemDelete((__bridge CFDictionaryRef)query);
        }
        !rv?:CFRelease(rv);
    }else if (err == errSecItemNotFound){
        if(obj){
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
            [query setValue:data forKey:(id)kSecValueData];
            err = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        }
    }
}

@end
