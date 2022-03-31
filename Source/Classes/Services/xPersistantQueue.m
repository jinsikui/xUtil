

#import "xPersistantQueue.h"
#import <objc/runtime.h>
#if __has_include(<fmdb/FMDB.h>)
#import <fmdb/FMDB.h>
#else
#import "FMDB.h"
#endif
#import "xError.h"
#import "xFile.h"


@interface NSObject (xPersistantQueue)

@property(nonatomic,assign) long x_persistantQueueId;

@end

@implementation NSObject (xPersistantQueue)

- (void)setX_persistantQueueId:(long)x_persistantQueueId{
    objc_setAssociatedObject(self, @selector(x_persistantQueueId), @(x_persistantQueueId), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)x_persistantQueueId{
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) {
        return 0;
    }
    else{
        return [value longValue];
    }
}
@end


typedef enum xPersistantQueueState{
    xPersistantQueueStateReady = 0,
    xPersistantQueueStateProcessing
} xPersistantQueueState;


static NSString * const xPQTableName = @"t_queue";
static NSString * const xPQPrimaryColumnName = @"id";
static NSString * const xPQDataColumnName = @"data";


@interface xPersistantQueue()
@property (nonatomic, copy) NSString *sqlFilePath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, assign) xPersistantQueueState state;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation xPersistantQueue

+ (instancetype)queueWithName:(NSString*)name{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:name];
    return [[xPersistantQueue alloc] initWithPath:path];
}

+ (instancetype)queueWithPath:(NSString*)path{
    return [[xPersistantQueue alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString*)path{
    self = [super init];
    if(self){
        self.sqlFilePath = path;
        NSString *dirPath = [path stringByDeletingLastPathComponent];
        [xFile createFolder:dirPath];
        self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:self.sqlFilePath];
        self.lock = [NSLock new];
        [self createTableIfNotExist];
    }
    return self;
}

- (void)createTableIfNotExist {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ BLOB);", xPQTableName, xPQPrimaryColumnName, xPQDataColumnName];
        [db executeUpdate:sql];
    }];
}

- (void)deleteAll {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", xPQTableName];
        [db executeUpdate:sql];
    }];
}

- (void)inqueueData:(NSObject<NSCoding> *)data {
    __weak typeof(self) weak = self;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (?);", xPQTableName, xPQDataColumnName];
        NSData *archivedData;
        if (@available(iOS 11.0, *)) {
            NSError *error;
            archivedData = [NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:false error:&error];
            if (error) {
                return;
            }
        } else {
            archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];
        }
        BOOL isSuccess = [db executeUpdate:sql, archivedData];
        if (isSuccess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weak tryDequeue];
            });
        }
    }];
}

- (void)setProcessCallback:(xPersistantQueueProcessCallback)processCallback{
    _processCallback = processCallback;
    if(processCallback){
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weak tryDequeue];
        });
    }
}

- (void)tryDequeue{
    NSLock *lock = self.lock;
    BOOL isLocked = [lock tryLock];
    if(!isLocked){
        return;
    }
    xPersistantQueueProcessCallback callback = self.processCallback;
    if(!callback){
        [lock unlock];
        return;
    }
    xPersistantQueueState state = self.state;
    if(state != xPersistantQueueStateReady){
        [lock unlock];
        return;
    }
    self.state = xPersistantQueueStateProcessing;
    __weak xPersistantQueue *weak = self;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        __strong xPersistantQueue *s = weak;
        if(!s){
            [lock unlock];
            return;
        }
        NSObject *retData = nil;
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ LIMIT 1;", xPQTableName, xPQPrimaryColumnName];
        FMResultSet *result = [db executeQuery:sql];
        if (![result next]) {
            [result close];
            s.state = xPersistantQueueStateReady;
            [lock unlock];
            return;
        }
        
        NSData *data = [result dataForColumn:xPQDataColumnName];
        NSInteger Id = [result intForColumn:xPQPrimaryColumnName];
        NSError *error;
        retData = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:&error];
        if (!error) {
            retData.x_persistantQueueId = Id;
        }
        [result close];
        if(!retData){
            sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %ld;", xPQTableName, xPQPrimaryColumnName, (long)Id];
            [db executeUpdate:sql];
            s.state = xPersistantQueueStateReady;
            [lock unlock];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weak tryDequeue];
            });
            return;
        }
        xPersistantQueueProcessCallback callback = s.processCallback;
        if(!callback){
            s.state = xPersistantQueueStateReady;
            [lock unlock];
            return;
        }
        [lock unlock];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            callback(retData, s);
        });
    }];
}

- (void)completeProcessData:(NSObject *_Nullable)data{
    NSLock *lock = self.lock;
    [lock lock];
    if(!data){
        self.state = xPersistantQueueStateReady;
        [lock unlock];
        return;
    }
    __weak xPersistantQueue *weak = self;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        __strong xPersistantQueue *s = weak;
        if(!s){
            [lock unlock];
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %ld;", xPQTableName, xPQPrimaryColumnName, (long)data.x_persistantQueueId];
        [db executeUpdate:sql];
        s.state = xPersistantQueueStateReady;
        [lock unlock];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weak tryDequeue];
        });
    }];
}

@end
