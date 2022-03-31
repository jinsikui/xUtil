

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 本类中的arrKey必须对应一个已经初始化（不为nil）的NSArray数组
@interface NSObject(xKVO)

-(void)x_addObject:(id)object toArrKey:(NSString*)arrKey;

-(void)x_addObjects:(NSArray*)objects toArrKey:(NSString*)arrKey;

-(void)x_insertObject:(id)object atIndex:(NSUInteger)index toArrKey:(NSString*)arrKey;

-(void)x_removeObject:(id)object fromArrKey:(NSString*)arrKey;

-(void)x_removeObjects:(NSArray*)objects fromArrKey:(NSString*)arrKey;

-(void)x_removeObjectAtIndex:(NSUInteger)index fromArrKey:(NSString*)arrKey;

-(void)x_replaceObjectAtIndex:(NSUInteger)index byObject:(id)object fromArrKey:(NSString*)arrKey;


@end

NS_ASSUME_NONNULL_END
