

#import "xStore.h"
#import "xFile.h"
#import "xUtil.h"

@interface xStore()

@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *path;

@end

@implementation xStore

+(instancetype)defaultStore{
    return [self storeByName:@"default"];
}

+(instancetype)storeByName:(NSString*)name{
    return [[xStore alloc] initWithName:name];
}

-(instancetype)initWithName:(NSString*)name{
    self = [super init];
    if(self){
        NSString *folderPath = [xFile appSupportPath:@"xstore"];
        [xFile createFolder:folderPath];
        _name = name;
        _path = [folderPath stringByAppendingPathComponent:[xFile strToMD5:name]];
        if(![xFile fileExistsAtPath:_path]){
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [xFile saveDic:dic toPath:_path];
        }
    }
    return self;
}

-(id _Nullable)objectForKeyedSubscript:(NSString*)key{
    @synchronized (xStore.class) {
        NSMutableDictionary *dic = (NSMutableDictionary*)[xFile getDicFromFileOfPath:_path];
        return dic[key];
    }
}

-(void)setObject:(id<NSCoding>)obj forKeyedSubscript:(NSString *)key{
    BOOL notValidObject = (obj && ![xFile verifyArchivable:obj]);
    if (notValidObject) {
        NSLog(@"[xStore] %@ failed : %@ -> %@", NSStringFromSelector(_cmd), key, obj);
        return;
    }

    @synchronized (xStore.class) {
        NSMutableDictionary *dic = (NSMutableDictionary*)[xFile getDicFromFileOfPath:_path];
        if (obj) {
            dic[key] = obj;
        } else {
            [dic removeObjectForKey:key];
        }
        [xFile saveDic:dic toPath:_path];
    }
}

@end
