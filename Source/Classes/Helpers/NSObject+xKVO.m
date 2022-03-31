

#import "NSObject+xKVO.h"

@implementation NSObject(xKVO)

-(void)x_addObject:(id)object toArrKey:(NSString*)arrKey{
    NSMutableArray *arr = [self mutableArrayValueForKey:arrKey];
    [arr addObject:object];
}

-(void)x_addObjects:(NSArray*)objects toArrKey:(NSString*)arrKey{
    NSMutableArray *arr = [self mutableArrayValueForKey:arrKey];
    [arr insertObjects:objects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(arr.count, objects.count)]];
}

-(void)x_insertObject:(id)object atIndex:(NSUInteger)index toArrKey:(NSString*)arrKey{
    NSMutableArray *arr = [self mutableArrayValueForKey:arrKey];
    [arr insertObject:object atIndex:index];
}

-(void)x_removeObject:(id)object fromArrKey:(NSString*)arrKey{
    NSMutableArray *arr = [self mutableArrayValueForKey:arrKey];
    [arr removeObject:object];
}

-(void)x_removeObjects:(NSArray*)objects fromArrKey:(NSString*)arrKey{
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    NSMutableArray *arr = [self mutableArrayValueForKey:arrKey];
    for(id obj in objects){
        if([arr containsObject:obj]){
            NSUInteger idx = [arr indexOfObject:obj];
            [indexes addIndex:idx];
        }
    }
    [arr removeObjectsAtIndexes:indexes];
}

-(void)x_removeObjectAtIndex:(NSUInteger)index fromArrKey:(NSString*)arrKey{
    NSMutableArray *arr = [self mutableArrayValueForKey:arrKey];
    [arr removeObjectAtIndex:index];
}

-(void)x_replaceObjectAtIndex:(NSUInteger)index byObject:(id)object fromArrKey:(NSString*)arrKey{
    NSMutableArray *arr = [self mutableArrayValueForKey:arrKey];
    [arr replaceObjectAtIndex:index withObject:object];
}

@end
