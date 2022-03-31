# <a name="top"></a>xUtil

* [概述](#概述)
* [安装](#安装)
* [使用](#使用)
* [xTask](#xtask)
* [xTimer](#xtimer)
* [xFont](#xfont)
* [xColor](#xcolor)
* [xDevice](#xdevice)
* [xFile](#xfile)
* [xStore](#xstore)
* [xKeychainStore](#xkeychainstore)
* [集合操作](#set)
* [xUrlHelper](#xurlhelper)
* [promise生成](#promise)
* [promise](#promisestudy)
   * [promise是什么](#promisewhat)
   * [创建](#promisecreate)
   * [使用](#promiseuse)
   * [操作符](#promiseoperator)
   * [说明](#promisenotice)
      * [线程](#promisethread)
      * [循环引用](#promisecycleref)
      * [执行时机](#promiseexecute)

## 概述

业务无关的iOS工具组件库，支持ObjC & Swift

## 安装

通过pod引用，在podfile增加下面一行，通过tag指定版本
```
pod 'xUtil',        :git => "https://github.com/jinsikui/xUtil.git", :tag => 'vX.X.X-X'
```
 objc代码中引入：
```
#import <xUtil/xUtil.h>
```
 swift代码中引入：
```
在项目的plist文件中配置置 'Objective-C Bridging Header = xxx.h'，在xxx.h中添加一行：
#import <xUtil/xUtil.h>
```

## 使用

### xTask 
[回顶](#top) 

```
简化异步执行，延迟执行
```
#### 用法
```swift
// 异步到主线程执行
xTask.asyncMain {
   LiveViewHelper.showToast(msg)
}

// 如果当前就在主线程，同步执行，否则异步到主线程执行
xTask.executeMain {
   LiveViewHelper.showToast(msg)
}

xTask.asyncGlobal(after: 3) {
   // 3秒后在global线程执行
}

xTask.async(queue, after: 5) {
   // 5秒后在queue对应的线程执行 ...
}
```
### xTimer 
[回顶](#top) 

```
封装GCD timer
```
#### 用法
```swift
// 启动timer
let timer = xTimer.init(intervalSeconds: 10, queue: queue, fireOnStart: false) {[weak self] in
   // do work on queue ...
}
// or
let timer = xTimer.init(onMainWithIntervalSeconds: 10, fireOnStart: false) {[weak self] in
   // do work on main thread ...
}
timer.start() //可重入

// 暂停timer
timer.stop() //可重入
```
### xFont 
[回顶](#top) 

```
创建字体
```
#### 用法
```swift
label.font = xFont.regularPF(withSize: 12)
label2.font = xFont.semiboldPF(withSize: 12)

// objc中可以使用宏定义
label.font = kFontRegularPF(12)
label2.font = kFontSemiboldPF(12)
```
### xColor
[回顶](#top) 

```
创建颜色
```
#### 用法
```swift
view.backgroundColor = xColor.fromRGB(0xFFF2B8)
view2.backgroundColor = xColor.fromRGBA(0x686E7E, alpha: 0.6)
let str = "#0238EF"
view3.backgroundColor = xColor.fromHexStr(str)

// objc中可以使用宏定义
view1.backgroundColor = kColor(0xFFF2B8)
view2.backgroundColor = kColorA(0xFFF2B8, 0.6)
```
### xDevice 
[回顶](#top) 

```
设备相关的属性
```
#### 用法
```swift
var h = xDevice.statusBarHeight() // 状态栏高度
var w = xDevice.screenWidth() // 屏幕宽度
h = xDevice.screenHeight() // 屏幕高
h = xDevice.bottomBarHeight() // 底部刘海高
h = xDevice.navBarHeight() // 导航栏高（不包含statusBar高度）
var deviceId = xDevice.deviceId() // 设备Id，可通过provider配置
var bundleId = xDevice.bundleId() // bundleId
var appVersion = xDevice.appVersion() // CFBundleShortVersionString
// ......
// objc中可以使用宏定义
var h = kStatusBarHeight // 状态栏高度
var w = kScreenWidth // 屏幕宽度
h = kScreenHeight // 屏幕高
h = kNavBarHeight // 导航栏高（不包含statusBar高度）
```
### xFile 
[回顶](#top) 

```
操作文件/json转化/对象持久化/base64/md5
```
#### 用法
```swift
// 文件读写
let filename = "test.png"
let path = xFile.documentPath(filename)
let data = xFile.getDataFromFileOfPath(path)
xFile.save(data!, toPath: path)

// json转化
var jsonStr = "{\"name\": \"JSK\"}"
let dic = xFile.jsonStr(toObject: jsonStr) as! [String:AnyObject] // json字符串转对象（字典，数组）
jsonStr = xFile.object(toJsonStr: dic)! // 对象转json字符串

// 对象持久化
let dic = ...
xFile.saveDic(dic, toPath: xFile.appSupportPath("live.config")) // 字典持久化（archive）到磁盘
let dic = xFile.getDicFromFileOfPath(xFile.appSupportPath("live.config")) // 磁盘unarchive到字典

// base64/md5
let md5Str = xFile.str(toMD5: str) // String -> md5
let md5Str = xFile.data(toMD5: data) // Data -> md5
let data = xFile.base64(toData: str) // base64 -> Data
let base64 = xFile.data(toBase64: data) // Data -> base64
// ......
```
### xStore 
[回顶](#top) 

```
持久化数据至磁盘，内部使用字典和archive机制，因为是IO整个字典，应避免将大量数据存入，大量数据应使用sqlite数据库实现
```
#### 用法
```objc
// 取
xStore *store = [xStore storeByName:@"testConfig"];
BOOL isPlayed = store[@"isPlayed"].boolValue;

// 存
store[@"lastPlayedTime"] = [NSDate date];
```

### xKeychainStore 
[回顶](#top) 

```
持久化数据至用户keychain，卸载重装app数据仍然会保留
```
#### 用法
```objc
// 取
xKeychainStore *kStore = [xKeychainStore storeWithName:@"userAuth"];
NSString *phone = kStore[@"phone"];
if(!phone){
   // ...
}
// 存
kStore[@"pw"] = password;
```

### <a name="set"></a> 集合操作
[回顶](#top) 

```
快捷遍历/过滤/查找/map
```
#### 用法
```objc
NSArray<NSDictionary*> *arr = apiRet["users"];
// map
NSArray<LiveUser*> *users = [arr x_map:^id _Nonnull(NSDictionary * _Nonnull item) {
   return [[LiveUser alloc] initWithDic:item];
}];
// 过滤
NSArray<LiveUser*> *followedUsers = [users x_filter:^BOOL(LiveUser * _Nonnull item) {
   return item.isFollowed == true;
}];
// 遍历
[followedUsers x_each:^(LiveUser * _Nonnull item) {
   // do some work with each item ...
}];
// 查找
LiveUser *user = [users x_first:^BOOL(LiveUser * _Nonnull item) {
   return [item.userId isEqualToString:userId];
}];
if(user){
   // do with the user ...
}
```

### xUrlHelper 
[回顶](#top) 

```
生成url，获取url信息
```
#### 接口
```objc
@interface xUrlHelper : NSObject

/// url编码
+ (NSString *)urlEncode:(NSString *)input;

/// url解码
+ (NSString *)urlDecode:(NSString *)input;

/// 将query参数添加到url中
/// @param input url
/// @param params query参数
+ (NSString *)mergeToInput:(NSString *)input queryParams:(NSDictionary *)params;

/// 在给定url的query中找到第一个key相同的
/// @param url 给定rul
/// @param name key
+ (NSString * __nullable)queryValueIn:(NSString *)url name:(NSString *)name;

/// url的host地址
+ (NSString * __nullable)hostFor:(NSString *)url;

/// url的路径
+ (NSString * __nullable)pathFor:(NSString *)url;

/// url的query
+ (NSDictionary<NSString *, NSString *> * __nullable)paramsFor:(NSString *)url;

@end
```

### <a name="promise"></a> promise生成
[回顶](#top) 

```
结合FBLPromise使用，提供快捷生成几种promise的方法
扩展方法作用在NSObject上，多数情况下可以通过self.直接调用
```
#### 接口
```objc
@interface NSObject (xExtension)

/// 创建一个reject状态的promise
/// @param code 错误码
/// @param errorMsg 错误信息
- (FBLPromise*)x_rejectedPromiseWithCode:(NSInteger)code msg:(NSString* __nullable)errorMsg;

/// 创建一个reject状态的promise
/// @param errorMsg 错误信息
- (FBLPromise*)x_rejectedPromise:(NSString * __nullable)errorMsg;

/// 创建一个fufill的promise
/// @param data 传回参数
- (FBLPromise*)x_fulfilledPromise:(id __nullable)data;

/// 创建一个下载图片的promise
/// @param imgUrl 图片url
- (FBLPromise<UIImage*>*)x_downloadImgPromise:(NSString*)imgUrl;

/// 创建一个获取data的promise
/// @param url dataUrl
- (FBLPromise<NSData*>*)x_getDataPromise:(NSString *)url;

/// 创建一个下载文件的promise，若下载成功，fullfil返回downloadFilePath
/// @param url 文件url
/// @param downloadFilePath 存放地址
- (FBLPromise<NSString*>*)x_downloadFilePromise:(NSString*)url downloadFilePath:(NSString*)downloadFilePath;

/// 创建一个延迟执行promise
/// @param queue 执行的队列
/// @param interval 延迟时间
- (FBLPromise*)x_delayPromiseOn:(dispatch_queue_t)queue interval:(NSTimeInterval)interval;

/// 创建一个在主队列延迟执行promise
/// @param interval 延迟时间
- (FBLPromise*)x_delayPromiseOnMainInterval:(NSTimeInterval)interval;

/// 创建一个在全局队列延迟执行promise
/// @param interval 延迟时间
- (FBLPromise*)x_delayPromiseOnGlobalInterval:(NSTimeInterval)interval;

@end
```

#### 用法举例
```swift

/// 发送入场消息
-(FBLPromise*)postEnter{
   if(![UserModel isLogin]){
      return [self x_rejectedPromise:@"未登陆"];
   }
   if(self.hasPostEnter){
      return [self x_fulfilledPromise:@"已发送过入场消息"];
   }
   return [JBAPI.shared postEnterForRoom:self.room.roomId].then(^id(NSDictionary *ret){
      self.hasPostEnter = true;
      return nil;
   });
}

/// 执行动画
-(FBLPromise*)executeAnimationOn:(UIView*)trackView{
   // 下载图片的两个promise
   FBLPromise *p1 = [self x_downloadImgPromise:self.animalImgUrl];
   FBLPromise *p2 = [self x_downloadImgPromise:self.barImgUrl];
   // 等两个图片下载完毕
   FBLPromise *p3 = [FBLPromise all:@[p1,p2]];
   // 执行动画promise
   FBLPromise *p4 = p3.then(^id(NSArray *arr){
      // 使用两个图片
      self.imgView.image = arr[0];
      self.barImgView.image = arr[1];
      [trackView addSubview:self];
      // p5用于等待动画执行完成返回
      FBLPromise *p5 = FBLPromise.pendingPromise;
      self.frame = CGRectMake(kScreenWidth, -136, 234, 30+136);
      self.alpha = 0;
      [UIView animateWithDuration:15.f/30.f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
         self.alpha = 1;
         self.frame = CGRectMake(12, -136, 234, 30+136);
      } completion:^(BOOL finished) {
         [self removeFromSuperview];
         [p5 fulfill:nil];
      }];
      return p5;
   });
   return p4;
}
```

### <a name="promisestudy"></a> promise
[回顶](#top) 

```
简单介绍一下FBLPromise的使用
```
#### <a name="promisewhat"></a> promise是什么

github：https://github.com/google/promises
```
promise是一个简化异步任务的库，一个promise对象可看作是一个会在未来完成(或已经完成)的事件
```
pod引用：
```
pod 'PromisesObjC'
pod 'PromisesSwift'
```
#### <a name="promisecreate"></a> 创建
方式一（使用block）：
```swift
-(FBLPromise*)create:(PurchaseItem*)item {
   FBLPromise *promise = [FBLPromise async:^(FBLPromiseFulfillBlock  _Nonnull fulfill, FBLPromiseRejectBlock  _Nonnull reject) {
      [[PurchaseManager shareManager] purchaseWithItem:purchaseItem viewController:self onSucceed:^{
         
         fulfill(nil);

      } onFailed:^(NSError * _Nullable error) {
         
         reject([NSError errorWithCode:-1 message:@"购买失败, 请重试"]);

      }];
   }];
   return promise;
}
```
方式二（使用pendingPromise）：
```swift
/// 异步完成
-(FBLPromise*)create {
   FBLPromise *promise = FBLPromise.pendingPromise;
   self.frame = CGRectMake(kScreenWidth, -136, 234, 30+136);
   self.alpha = 0;
   [UIView animateWithDuration:15.f/30.f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
      self.alpha = 1;
      self.frame = CGRectMake(12, -136, 234, 30+136);
   } completion:^(BOOL finished) {
      if(!finished){
         [promise reject:[NSError errorWithCode:-1 message:@"动画执行失败"];
      }
      else{
         [promise fulfill:nil];
      }
   }];
   return promise;
}

/// 同步（完成）
-(FBLPromise*)createFulfilledPromise:(id _Nullable)ret {
   FBLPromise *promise = FBLPromise.pendingPromise;
   [promise fulfill:ret];
   return promise;
}

/// 同步（失败）
-(FBLPromise*)createRejectedPromise:(NSString*)errorMsg {
   FBLPromise *promise = FBLPromise.pendingPromise;
   [promise reject:[NSError errorWithCode:-1 message:errorMsg]];
   return promise;
}
```
#### <a name="promiseuse"></a> 使用
```
通过"then catch always all any recover ..." 等操作符使用
```
```swift
/// 发送入场消息
-(FBLPromise*)postEnter{
   if(![UserModel isLogin]){
      return [self createRejectedPromise:@"未登陆"];
   }
   if(self.hasPostEnter){
      return [self createFulfilledPromise:@"已发送过入场消息"];
   }
   return [JBAPI.shared postEnterForRoom:self.room.roomId].then(^id(NSDictionary *ret){
      self.hasPostEnter = true;
      return nil;
   });
}

- (void)viewDidLoad {
   // ...
   [self postEnter].then(^id(id ret){
      // do other work after post enter
      return nil;

   }).catch(^(NSError *error){
      // show error
      xToask.show(error.message);
      
   }).always(^{
      // do some work
   });
}
```

#### <a name="promiseoperator"></a> 操作符
```
promise通过操作符使用上一步的结果，返回新的promise，形成链式结构
特别说明：then操作符可以返回nil，一般对象，NSError，另一个promise
```
```swift
-(FBLPromise*) showThenUsage{
   return [self doTask].then(^id(id ret1){
      // do with ret1 and get ret2
      SomeClass *ret2 = ...
      return ret2;

   }).then(^id(id ret){
      // do some work with ret2
      return nil;

   }).then(^id(id ret){
      // do some work by new promise 
      return [self createAnotherPromiese];

   }).then(^id(id ret){
      // do with new task ret, and fail
      return [NSError errorWithCode:-1 message:"got error"];

   }).catch(^(NSError *error){
      // handle with error, no return

   }).recover(^(NSError *error){
      // resolve error, return ret3
      SomeClass *ret3 = ...
      return ret3;

   }).then(^id(id ret){
      // do work with ret3
      return ret;
   })
}
```
一个复杂点的例子：

```swift
/// 执行动画：
/// all(p1,p2).then( return new promise)
-(FBLPromise*)executeAnimationOn:(UIView*)trackView{
   // 下载图片的两个promise
   FBLPromise *p1 = [self x_downloadImgPromise:self.animalImgUrl];
   FBLPromise *p2 = [self x_downloadImgPromise:self.barImgUrl];
   // 等两个图片下载完毕
   FBLPromise *p3 = [FBLPromise all:@[p1,p2]];
   // 执行动画promise
   FBLPromise *p4 = p3.then(^id(NSArray *arr){
      // 使用两个图片
      self.imgView.image = arr[0];
      self.barImgView.image = arr[1];
      [trackView addSubview:self];
      // p5用于等待动画执行完成返回
      FBLPromise *p5 = FBLPromise.pendingPromise;
      self.frame = CGRectMake(kScreenWidth, -136, 234, 30+136);
      self.alpha = 0;
      [UIView animateWithDuration:15.f/30.f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
         self.alpha = 1;
         self.frame = CGRectMake(12, -136, 234, 30+136);
      } completion:^(BOOL finished) {
         if(finished){
            [self removeFromSuperview];
            [p5 fulfill:nil];
         }
         else {
            [p5 reject:[NSError errorWithCode:-1 message:@"动画失败"]];
         }
      }];
      return p5;
   });
   return p4;
}
```

#### <a name="promisenotice"></a> 说明

##### <a name="promisethread"></a> 线程
```
通过block创建promise，或通过操作符使用promise，不指定线程的话，会异步至主线程执行，可以通过传入queue来指定在其它线程执行
```
```swift
FBLPromise.asyncOn(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(FBLPromiseFulfillBlock fulfill,
                                                                                    FBLPromiseRejectBlock reject) {
   // do async task on global thread ...
   NSDictionary *dic = ...
   fulfill(dic);

}).thenOn(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^id(NSDictionary *dic){
   // do with ret on global thread ...
   return nil;
});
```

##### <a name="promisecycleref"></a> 循环引用

```
promise本身不会引用传入的block，底层会将block交给GCD执行，GCD执行完成后就会释放block，
所以在block中使用“self”的话，会在GCD执行结束后解除对self的引用，但是如果执行的是长时间操作，还是应该使用__weak
```

##### <a name="promiseexecute"></a> 执行时机

```
promise链不需要先构造好整个链再统一的启动，最底层的promise在创建时就开始执行block中的代码
外层可以随时，通过操作符使用promise，比如在调用then时，如果此时内层promise已经fulfill，then会立刻触发，否则会等内层未来fulfill时触发

```






