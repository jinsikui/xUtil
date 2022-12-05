
#import "MainViewController.h"
#import "xUtil.h"
#import "xUI.h"
#import "Masonry.h"
#import "ReactiveObjC.h"

@interface SubModel : NSObject
@property(nonatomic, assign) CGFloat width;
@end

@implementation SubModel
@end


@interface MainViewController () {
    BOOL _isLoading;
    int _indicater;
    RACSubject *_letters;
    RACSubject *_numbers;
    RACDisposable *_finalDisposable;
    RACSubject<NSString*> *_throttleSubject;
    RACSignal<NSString*> *_throttleSignal;
}
@property(nonatomic, strong) UIScrollView *scroll;
@property(nonatomic, assign) CGFloat currentY;
@property(nonatomic, strong) RACSignal *signal;
@property(nonatomic, strong) RACSubject *subject;
@property(nonatomic, strong) RACReplaySubject *replaySubject;
@property(nonatomic, strong) NSDate *createTime;
@property(nonatomic, assign) CGSize targetSize;
@property(nonatomic, assign) CGRect targetFrame;
@property(nonatomic, assign) NSString *testProp;
// 测试绑定
@property(nonatomic, strong) SubModel *subModel;
@property(nonatomic, assign) CGFloat width;
@end

@implementation MainViewController

#pragma mark - life circle
- (instancetype)init {
    if (self = [super init]) {
        self.currentY = 30;
        self.createTime = [NSDate date];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"page(%@) dealloc", self.createTime);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self setupUI];
}

#pragma mark - UI func
- (void)setupUI { 
    self.title = @"xUtil Test";
    self.view.backgroundColor = kColor(0xFFFFFF);
    _scroll = [[UIScrollView alloc] init];
    _scroll.alwaysBounceVertical = true;
    [self.view addSubview:_scroll];
    [_scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self addBtn:@"hellow" selector:@selector(actionHellow)];
    [self addBtn:@"RACDeliver" selector:@selector(actionRACDeliver)];
    [self addBtn:@"RACSubject" selector:@selector(actionRACSubject)];
    [self addBtn:@"RACReplaySubject" selector:@selector(actionRACReplaySubject)];
    [self addBtn:@"RAC register notification" selector:@selector(actionRACRegisterNotification)];
    [self addBtn:@"Post Notification" selector:@selector(actionPostNotification)];
    [self addBtn:@"push page again" selector:@selector(actionPushMain)];
    [self addBtn:@"CABasicAnimation" selector:@selector(actionCABasicAnimation)];
    [self addBtn:@"RAC binding" selector:@selector(actionRACBinding)];
    [self addBtn:@"New Font" selector:@selector(actionNewFont)];
    [self addBtn:@"RAC CombineLatest" selector:@selector(actionRACCombineLatest)];
    [self addBtn:@"RAC Signal lifetime" selector:@selector(actionRACSignalLifetime)];
    [self addBtn:@"RAC merge" selector:@selector(actionRACMerge)];
    [self addBtn:@"RAC flattenMap" selector:@selector(actionFlattenMap)];
    [self addBtn:@"RAC flattenMap dispose" selector:@selector(actionFlattenMapDispose)];
    [self addBtn:@"RAC then" selector:@selector(actionRACThen)];
    [self addBtn:@"RAC throttle" selector:@selector(actionRACThrottle)];
    [self addBtn:@"RAC throttle trigger" selector:@selector(actionRACThrottleTrigger)];
    [self addBtn:@"RAC throttle complete" selector:@selector(actionRACThrottleComplete)];
    [self addBtn:@"RAC trigger/binding time" selector:@selector(actionRACTime)];
    
    RAC(self, targetSize) = [[RACObserve(self.scroll, frame) map:^id _Nullable(id  _Nullable value) {
        return @([value CGRectValue].size);
    }] distinctUntilChanged];
    _scroll.contentSize = CGSizeMake(0, self.currentY);
}

-(UIButton *)addBtn:(NSString*)text selector:(SEL)selector{
    UIButton *btn = [xViewFactory buttonWithTitle:text font:kFontRegularPF(12) titleColor:kColor(0) bgColor:xColor.clearColor borderColor:kColor(0) borderWidth:0.5];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0.5 * (xDevice.screenWidth - 200), self.currentY, 200, 40);
    [self.scroll addSubview:btn];
    self.currentY += 50;
    return btn;
}

#pragma mark - Actions

- (void)actionRACTime {
    /**
     2022-12-05 15:19:44.030578+0800 xUtil[13648:2004758] actionRACTime, thread: <_NSMainThread: 0x600002b4c740>{number = 1, name = main}
     2022-12-05 15:19:44.031759+0800 xUtil[13648:2004758] RACObserve(self, width).subscribeNext: self.width = 0, self.subModel.width = 0, thread: <_NSMainThread: 0x600002b4c740>{number = 1, name = main}
     2022-12-05 15:19:44.032354+0800 xUtil[13648:2004758] RACObserve(self.subModel, width).subscribeNext: self.width = 0, self.subModel.width = 0, thread: <_NSMainThread: 0x600002b4c740>{number = 1, name = main}
     2022-12-05 15:19:44.032560+0800 xUtil[13648:2004758] after setup observation: <_NSMainThread: 0x600002b4c740>{number = 1, name = main}
     2022-12-05 15:19:47.032984+0800 xUtil[13648:2004981] before set width, thread: <NSThread: 0x600002b11b00>{number = 3, name = (null)}
     2022-12-05 15:19:47.033618+0800 xUtil[13648:2004977] RACObserve(self, width).subscribeNext: self.width = 100, self.subModel.width = 0, thread: <NSThread: 0x600002b18440>{number = 4, name = (null)}
     2022-12-05 15:19:47.033673+0800 xUtil[13648:2004981] after set width: self.width = 100, self.subModel.width = 0, thread: <NSThread: 0x600002b11b00>{number = 3, name = (null)}
     2022-12-05 15:19:47.033996+0800 xUtil[13648:2004977] RACObserve(self.subModel, width).subscribeNext: self.width = 100, self.subModel.width = 100, thread: <NSThread: 0x600002b18440>{number = 4, name = (null)}
     */
    NSLog(@"actionRACTime, thread: %@", NSThread.currentThread);
    self.subModel = [SubModel new];
    RAC(self.subModel, width) = RACObserve(self, width);
    [RACObserve(self, width) subscribeNext:^(id  _Nullable x) {
        NSLog(@"RACObserve(self, width).subscribeNext: self.width = %@, self.subModel.width = %@, thread: %@", @(self.width), @(self.subModel.width), NSThread.currentThread);
    }];
    [RACObserve(self.subModel, width) subscribeNext:^(id  _Nullable x) {
        NSLog(@"RACObserve(self.subModel, width).subscribeNext: self.width = %@, self.subModel.width = %@, thread: %@", @(self.width), @(self.subModel.width), NSThread.currentThread);
    }];
    NSLog(@"after setup observation: %@", NSThread.currentThread);
    [xTask asyncGlobalAfter:3 task:^{
        NSLog(@"before set width, thread: %@", NSThread.currentThread);
        self.width = 100;
        NSLog(@"after set width: self.width = %@, self.subModel.width = %@, thread: %@", @(self.width), @(self.subModel.width), NSThread.currentThread);
    }];
}

// 发送complete之后，之前被throttle等待的sendNext会立刻发送出去
-(void)actionRACThrottleComplete {
    [_throttleSubject sendCompleted];
}

-(void)actionRACThrottleTrigger {
    [_throttleSubject sendNext:[NSString stringWithFormat:@"AAA%@",[NSDate date]]];
}

-(void)actionRACThrottle {
    _throttleSubject = [RACSubject subject];
    _throttleSignal = [_throttleSubject throttle:2];
    [_throttleSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"throttle subject: %@", x);
    }];
}

-(void)actionRACMerge {
    RACSubject *s1 = [RACSubject subject];
    RACSubject *s2 = [RACSubject subject];
    [[RACSignal merge:@[s1, s2]] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    [s1 sendNext:@(1)];
    [s1 sendNext:@(2)];
    [s2 sendNext:@"A"];
}


-(void)actionRACSignalLifetime {
    [_letters sendNext:@"D"];
    [_numbers sendNext:@"4"];
    self.testProp = @"JSK";
}

-(void)actionRACCombineLatest {
    [self.rac_willDeallocSignal subscribeCompleted:^{
        NSLog(@"MainViewController dealloc");
    }];
    _letters = [RACSubject subject];
    _numbers = [RACSubject subject];
     [_letters.rac_willDeallocSignal subscribeCompleted:^{
        NSLog(@"_letters signal dealloc");
    }];
     [_numbers.rac_willDeallocSignal subscribeCompleted:^{
        NSLog(@"_numbers signal dealloc");
    }];
    RACSignal *kvoSignal = RACObserve(self, testProp);
    [kvoSignal.rac_willDeallocSignal subscribeCompleted:^{
        NSLog(@"kvo signal dealloc");
    }];
    RACSignal *combined = [RACSignal
                           combineLatest:@[ _letters, _numbers, kvoSignal]];

    // Outputs: B1 B2 C2 C3
    [combined subscribeNext:^(id x) {
        RACTuple *tuple = (RACTuple*)x;
        NSLog(@"%@%@%@", tuple.first, tuple.second, tuple.third);
    }];
    [combined.rac_willDeallocSignal subscribeCompleted:^{
        NSLog(@"combined signal dealloc");
    }];
    [_letters sendNext:@"A"];
    [_letters sendNext:@"B"];
    [_numbers sendNext:@"1"];
    [_numbers sendNext:@"2"];
    [_letters sendNext:@"C"];
    [_numbers sendNext:@"3"];
    
    // Outputs: kvo signal dealloc
    //          combined signal dealloc
    // but when you call actionRACSignalLifetime(), the signal function still work well, amazing!
}

-(void)actionNewFont {
    NSLog(@"===== %@", [UIFont familyNames]);
    UILabel *label = [[UILabel alloc] init];
    UIFont *font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:40];
    label.font = font;
    label.text = @"15";
    [self.view addSubview:label];
    [label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100);
        make.top.mas_equalTo(100);
    }];
    
}

-(void)setTargetSize:(CGSize)targetSize{
    NSLog(@"===== setTargetSize: %@", @(targetSize));
    _targetSize = targetSize;
}

-(void)setTargetFrame:(CGRect)targetFrame{
    NSLog(@"===== setTargetFrame: %@", @(targetFrame));
    _targetFrame = targetFrame;
}

-(void)actionRACBinding {
    CGRect frame = self.scroll.frame;
    if(_indicater == 0) {
        frame.size.height = 1000;
        _indicater = 1;
    }
    else {
        frame.size.height = 2000;
        _indicater = 0;
    }
    self.scroll.frame = frame;
    self.scroll.frame = frame; // 会被过滤掉
}

-(void)actionCABasicAnimation {
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.redColor;
    view.frame = CGRectMake(100, 100, 100, 100);
    view.tag = 1234;
    [self.view addSubview:view];
    [self startLoading];
}

static NSString *loadingAnimationKey = @"loadingAnimation";

- (void)startLoading {
    if (_isLoading) {
        return;
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.5);
    animation.toValue = @(1);
    animation.duration = 1;
    animation.repeatCount = HUGE_VALF;
    animation.autoreverses = true;
    [[self.view viewWithTag:1234].layer addAnimation:animation forKey:loadingAnimationKey];
    _isLoading = true;
    
    [xTask asyncMainAfter:5 task:^{
        [self stopLoading];
    }];
}

- (void)stopLoading {
    [[self.view viewWithTag:1234].layer removeAnimationForKey:loadingAnimationKey];
    _isLoading = false;
}

- (BOOL)isLoading {
    return _isLoading;
}

-(void)actionRACThen {
    /**
     (无error版本：)
     2022-11-05 22:28:51.540076+0800 xUtil[84490:5830984] firstLevel disposable created: 0x600003475980
     2022-11-05 22:28:51.540508+0800 xUtil[84490:5830984] final disposable created: 0x600001d6a220
     2022-11-05 22:29:01.071729+0800 xUtil[84490:5831097] firstLevel disposable block executed
     2022-11-05 22:29:01.072268+0800 xUtil[84490:5831100] secondLevel disposable created: 0x600003460d50
     2022-11-05 22:29:01.072678+0800 xUtil[84490:5831100] finalSignal.next: thenA
     2022-11-05 22:29:03.205595+0800 xUtil[84490:5831100] finalSignal.next: thenB
     2022-11-05 22:29:05.339183+0800 xUtil[84490:5831101] finalSignal.next: thenC
     2022-11-05 22:29:05.339382+0800 xUtil[84490:5831101] secondLevel disposable block executed
     2022-11-05 22:29:05.339539+0800 xUtil[84490:5831101] finalSignal.completed
     
     (secondLevel signal sendError版本：)
     2022-11-05 22:44:40.039117+0800 xUtil[84836:5841417] firstLevel disposable created: 0x60000208c900
     2022-11-05 22:44:40.039535+0800 xUtil[84836:5841417] final disposable created: 0x600000992290
     2022-11-05 22:44:49.563445+0800 xUtil[84836:5841639] firstLevel disposable block executed
     2022-11-05 22:44:49.564005+0800 xUtil[84836:5841640] secondLevel disposable created: 0x60000208c900
     2022-11-05 22:44:49.564543+0800 xUtil[84836:5841640] finalSignal.next: thenA
     2022-11-05 22:44:51.697547+0800 xUtil[84836:5841640] finalSignal.next: thenB
     2022-11-05 22:44:53.820866+0800 xUtil[84836:5841640] secondLevel disposable block executed
     2022-11-05 22:44:53.821337+0800 xUtil[84836:5841640] finalSignal.error: (null)
     
     结论：
     1. 1级signal执行完毕才会开始2级signal的执行，但是不会将1级signal的value传给2级
     2. 会自动在两级完成时执行两级各自的disposable的block
     3. 任何一级sendError都会导致final error，sendError后所在级的disposable的block也会执行
     */
    RACSignal<NSString*> *finalSignal = [[self _createFirstLevelSignal] then:^RACSignal * _Nonnull{
        return [self _createSecondLevelSignal:@"then"];
    }];
    _finalDisposable = [finalSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"finalSignal.next: %@", x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"finalSignal.error: %@", error);
    } completed:^{
        NSLog(@"finalSignal.completed");
    }];
    NSLog(@"final disposable created: %p", _finalDisposable);
}

-(void)actionFlattenMapDispose {
    [_finalDisposable dispose];
}

-(void)actionFlattenMap {
    /**
     (启动后一会手动按了"RAC flattenMap dispose"按钮： )
     2022-11-05 22:15:42.667677+0800 xUtil[84254:5823271] firstLevel disposable created: 0x600002d11290
     2022-11-05 22:15:42.667824+0800 xUtil[84254:5823271] secondLevel disposable created: 0x600002d11280
     2022-11-05 22:15:42.667958+0800 xUtil[84254:5823271] finalSignal.next: 1A
     2022-11-05 22:15:42.668564+0800 xUtil[84254:5823271] final disposable created: 0x60000040a7d0
     2022-11-05 22:15:44.761826+0800 xUtil[84254:5823400] finalSignal.next: 1B
     2022-11-05 22:15:45.800752+0800 xUtil[84254:5823400] secondLevel disposable created: 0x600002d150e0
     2022-11-05 22:15:45.800927+0800 xUtil[84254:5823400] finalSignal.next: 2A
     2022-11-05 22:15:46.882181+0800 xUtil[84254:5823400] finalSignal.next: 1C
     2022-11-05 22:15:46.882460+0800 xUtil[84254:5823400] secondLevel disposable block executed
     2022-11-05 22:15:47.459915+0800 xUtil[84254:5823271] firstLevel disposable block executed
     2022-11-05 22:15:47.460288+0800 xUtil[84254:5823271] secondLevel disposable block executed
     2022-11-05 22:15:47.909917+0800 xUtil[84254:5823400] secondLevel signal see disposed
     2022-11-05 22:15:49.000257+0800 xUtil[84254:5823402] firstLevel signal see disposed
     
     (启动后未手动按"RAC flattenMap dispose"按钮：)
     2022-11-05 22:33:52.107279+0800 xUtil[84575:5833858] firstLevel disposable created: 0x60000097da00
     2022-11-05 22:33:52.107569+0800 xUtil[84575:5833858] secondLevel disposable created: 0x6000009743f0
     2022-11-05 22:33:52.107786+0800 xUtil[84575:5833858] finalSignal.next: 1A
     2022-11-05 22:33:52.108087+0800 xUtil[84575:5833858] final disposable created: 0x600002073870
     2022-11-05 22:33:54.108370+0800 xUtil[84575:5833973] finalSignal.next: 1B
     2022-11-05 22:33:55.257946+0800 xUtil[84575:5834329] secondLevel disposable created: 0x600000965010
     2022-11-05 22:33:55.258191+0800 xUtil[84575:5834329] finalSignal.next: 2A
     2022-11-05 22:33:56.218956+0800 xUtil[84575:5834329] finalSignal.next: 1C
     2022-11-05 22:33:56.219339+0800 xUtil[84575:5834329] secondLevel disposable block executed
     2022-11-05 22:33:57.388128+0800 xUtil[84575:5834329] finalSignal.next: 2B
     2022-11-05 22:33:58.458231+0800 xUtil[84575:5834329] secondLevel disposable created: 0x600000978460
     2022-11-05 22:33:58.458671+0800 xUtil[84575:5834329] finalSignal.next: 3A
     2022-11-05 22:33:59.513361+0800 xUtil[84575:5834329] finalSignal.next: 2C
     2022-11-05 22:33:59.513969+0800 xUtil[84575:5834329] secondLevel disposable block executed
     2022-11-05 22:34:00.590298+0800 xUtil[84575:5833973] finalSignal.next: 3B
     2022-11-05 22:34:01.657314+0800 xUtil[84575:5834329] firstLevel disposable block executed
     2022-11-05 22:34:01.657369+0800 xUtil[84575:5833973] secondLevel disposable created: 0x60000097d9b0
     2022-11-05 22:34:01.657668+0800 xUtil[84575:5833973] finalSignal.next: 4A
     2022-11-05 22:34:02.696151+0800 xUtil[84575:5833973] finalSignal.next: 3C
     2022-11-05 22:34:02.696558+0800 xUtil[84575:5833973] secondLevel disposable block executed
     2022-11-05 22:34:03.766617+0800 xUtil[84575:5833973] finalSignal.next: 4B
     2022-11-05 22:34:05.886655+0800 xUtil[84575:5833973] finalSignal.next: 4C
     2022-11-05 22:34:05.886934+0800 xUtil[84575:5833973] secondLevel disposable block executed
     2022-11-05 22:34:05.887144+0800 xUtil[84575:5833973] finalSignal.completed
     
     结论：
     1.无论是1级还是2级，sendError都会立刻导致finalSignal error
     2.final disposable是flattenMap自动生成的，对它的操作会立刻传给两级level的disposable，然后两级level各自的signal就可以响应
     3. 如果不主动dispose finalDisposable，系统会自动在2级signal完成时执行secondDisposable的block（自动调了secondDisposable.dispose()?）
     */
    RACSignal<NSString*> *finalSignal = [[self _createFirstLevelSignal] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return [self _createSecondLevelSignal:value];
    }];
    _finalDisposable = [finalSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"finalSignal.next: %@", x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"finalSignal.error: %@", error);
    } completed:^{
        NSLog(@"finalSignal.completed");
    }];
    NSLog(@"final disposable created: %p", _finalDisposable);
}

-(RACSignal<NSString*> *)_createFirstLevelSignal {
    RACSignal<NSString*> *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
            NSLog(@"firstLevel disposable block executed");
        }];
        NSLog(@"firstLevel disposable created: %p", disposable);
        [subscriber sendNext:@"1"];
        [xTask asyncGlobalAfter:3 task:^{
            if (disposable.isDisposed) {
                NSLog(@"firstLevel signal see disposed");
                [subscriber sendCompleted];
                return;
            }
            [subscriber sendNext:@"2"];
            [xTask asyncGlobalAfter:3 task:^{
                if (disposable.isDisposed) {
                    NSLog(@"firstLevel signal see disposed");
                    [subscriber sendCompleted];
                    return;
                }
                [subscriber sendNext:@"3"];
                [xTask asyncGlobalAfter:3 task:^{
                    if (disposable.isDisposed) {
                        NSLog(@"firstLevel signal see disposed");
                        [subscriber sendCompleted];
                        return;
                    }
                    [subscriber sendNext:@"4"];
                    [subscriber sendCompleted];
//                    [subscriber sendError:nil]; // 此句可替换上面两句来做试验
                }];
            }];
        }];
        return disposable;
    }];
    return signal;
}

-(RACSignal<NSString*> *)_createSecondLevelSignal:(NSString*)firstSignalValue {
    RACSignal<NSString*> *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
            NSLog(@"secondLevel disposable block executed");
        }];
        NSLog(@"secondLevel disposable created: %p", disposable);
        [subscriber sendNext:[NSString stringWithFormat:@"%@A", firstSignalValue]];
        [xTask asyncGlobalAfter:2 task:^{
            if (disposable.isDisposed) {
                NSLog(@"secondLevel signal see disposed");
                [subscriber sendCompleted];
                return;
            }
            [subscriber sendNext:[NSString stringWithFormat:@"%@B", firstSignalValue]];
            [xTask asyncGlobalAfter:2 task:^{
                if (disposable.isDisposed) {
                    NSLog(@"secondLevel signal see disposed");
                    [subscriber sendCompleted];
                    return;
                }
                [subscriber sendNext:[NSString stringWithFormat:@"%@C", firstSignalValue]];
                [subscriber sendCompleted];
//                [subscriber sendError:nil]; // 此句可替换上面两句来做试验
            }];
        }];
        return disposable;
    }];
    return signal;
}

-(void)actionPushMain {
    MainViewController *main = [[MainViewController alloc] init];
    [self.navigationController pushViewController:main animated:true];
}

-(void)actionPostNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"test-notification" object:nil];
}

-(void)actionRACRegisterNotification {
    @weakify(self)
      // wrong! after self dealloc, the observer is still registerred!
//    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"test-notification" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
//        @strongify(self)
//        NSLog(@"page(%@) receive test-notification", self.createTime);
//    }];
       // correct!
//     [self.rac_deallocDisposable addDisposable:[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"test-notification" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
//         @strongify(self)
//         NSLog(@"page(%@) receive test-notification", self.createTime);
//     }]];
    // correct too!
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"test-notification" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSLog(@"page(%@) receive test-notification", self.createTime);
    }];
}

-(void)actionRACDeliver{
    [xTask asyncGlobal:^{
        self.signal = [[[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"send 1 in thread: %@", [NSThread currentThread]); // global number = 3
            [subscriber sendNext:@(1)];
            [subscriber sendCompleted];
            return [RACDisposable new];
        }]
        deliverOn:[RACScheduler scheduler]]
        map:^id _Nullable(id  _Nullable value) {
            NSLog(@"execute map in thread: %@", [NSThread currentThread]); // global number = 6
            return @([value integerValue] * 2);
        }]
        deliverOn:[RACScheduler mainThreadScheduler]]
        doNext:^(id  _Nullable x) {
            NSLog(@"after call deliver, do next in thread: %@", [NSThread currentThread]); // main
        }];
        [self.signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"subscribe call on thread: %@", [NSThread currentThread]); // main
        }];
    }];
}

-(void)actionRACSubject {
    /**
     first subscribe - get subject value: 1 thread: <NSThread: 0x60000095ff80>{number = 3, name = (null)}
     first subscribe - get subject value: 2 thread: <NSThread: 0x60000095ff80>{number = 3, name = (null)}
     first subscribe - get subject error thread: <NSThread: 0x60000095ff80>{number = 3, name = (null)}
     second subscribe - get subject value: 3 thread: <_NSMainThread: 0x600000918800>{number = 1, name = main}
     second subscribe - get subject completed thread: <_NSMainThread: 0x600000918800>{number = 1, name = main}
     */
    self.subject = [RACSubject subject];
    [[self.subject deliverOn:RACScheduler.scheduler] subscribeNext:^(id  _Nullable x) {
        NSLog(@"first subscribe - get subject value: %@ thread: %@", x, [NSThread currentThread]);
    } error:^(NSError * _Nullable error) {
        NSLog(@"first subscribe - get subject error thread: %@", [NSThread currentThread]);
    } completed:^{
        NSLog(@"first subscribe - get subject completed thread: %@", [NSThread currentThread]);
    }];
    [xTask asyncMainAfter:5 task:^{
        [self.subject sendNext:@(1)];
        [xTask asyncMainAfter:5 task:^{
            [self.subject sendNext:@(2)];
            [xTask asyncMainAfter:5 task:^{
                [self.subject sendError:nil];
                [self.subject subscribeNext:^(id  _Nullable x) {
                    NSLog(@"second subscribe - get subject value: %@ thread: %@", x, [NSThread currentThread]);
                } error:^(NSError * _Nullable error) {
                    NSLog(@"second subscribe - get subject error thread: %@", [NSThread currentThread]);
                } completed:^{
                    NSLog(@"second subscribe - get subject completed thread: %@", [NSThread currentThread]);
                }];
                [xTask asyncMainAfter:5 task:^{
                    // you can sendNext(:) after call sendCompleted() or sendError(:)
                    // the value will add to subject anyway, but the state will not change, still completed or error.
                    [self.subject sendNext:@(3)];
                    // call sendCompleted() will override previous sendError(:)
                    // but call sendError(:) will not override previous sendCompleted()
                    [self.subject sendCompleted];
                    [self.subject subscribeNext:^(id  _Nullable x) {
                        NSLog(@"third subscribe - get subject value: %@ thread: %@", x, [NSThread currentThread]);
                    } error:^(NSError * _Nullable error) {
                        NSLog(@"third subscribe - get subject error thread: %@", [NSThread currentThread]);
                    } completed:^{
                        NSLog(@"third subscribe - get subject completed thread: %@", [NSThread currentThread]);
                    }];
                }];
            }];
        }];
    }];
}

-(void)actionRACReplaySubject {
    /**
     first subscribe - get subject value: 1
     first subscribe - get subject value: 2
     first subscribe - get subject error
     second subscribe - get subject value: 1   thread: <NSThread: 0x600003e8a380>{number = 4, name = (null)}
     second subscribe - get subject value: 2   thread: <NSThread: 0x600003e901c0>{number = 3, name = (null)}
     second subscribe - get subject error   thread: <NSThread: 0x600003e901c0>{number = 3, name = (null)}
     third subscribe - get subject value: 1   thread: <_NSMainThread: 0x600003ec80c0>{number = 1, name = main}
     third subscribe - get subject value: 2   thread: <_NSMainThread: 0x600003ec80c0>{number = 1, name = main}
     third subscribe - get subject value: 3   thread: <_NSMainThread: 0x600003ec80c0>{number = 1, name = main}
     third subscribe - get subject completed   thread: <_NSMainThread: 0x600003ec80c0>{number = 1, name = main}
     */
    self.replaySubject = [RACReplaySubject subject];
    [[self.replaySubject deliverOn:RACScheduler.scheduler] subscribeNext:^(id  _Nullable x) {
        NSLog(@"first subscribe - get subject value: %@ thread: %@", x, [NSThread currentThread]);
    } error:^(NSError * _Nullable error) {
        NSLog(@"first subscribe - get subject error thread: %@", [NSThread currentThread]);
    } completed:^{
        NSLog(@"first subscribe - get subject completed thread: %@", [NSThread currentThread]);
    }];
    [xTask asyncMainAfter:5 task:^{
        [self.replaySubject sendNext:@(1)];
        [xTask asyncMainAfter:5 task:^{
            [self.replaySubject sendNext:@(2)];
            [xTask asyncMainAfter:5 task:^{
                [self.replaySubject sendError:nil];
                [self.replaySubject subscribeNext:^(id  _Nullable x) {
                    NSLog(@"second subscribe - get subject value: %@ thread: %@", x, [NSThread currentThread]);
                } error:^(NSError * _Nullable error) {
                    NSLog(@"second subscribe - get subject error thread: %@", [NSThread currentThread]);
                } completed:^{
                    NSLog(@"second subscribe - get subject completed thread: %@", [NSThread currentThread]);
                }];
                [xTask asyncMainAfter:5 task:^{
                    // you can sendNext(:) after call sendCompleted() or sendError(:)
                    // the value will add to subject anyway, but the state will not change, still completed or error.
                    [self.replaySubject sendNext:@(3)];
                    // call sendCompleted() will override previous sendError(:)
                    // but call sendError(:) will not override previous sendCompleted()
                    [self.replaySubject sendCompleted];
                    [self.replaySubject subscribeNext:^(id  _Nullable x) {
                        NSLog(@"third subscribe - get subject value: %@ thread: %@", x, [NSThread currentThread]);
                    } error:^(NSError * _Nullable error) {
                        NSLog(@"third subscribe - get subject error thread: %@", [NSThread currentThread]);
                    } completed:^{
                        NSLog(@"third subscribe - get subject completed thread: %@", [NSThread currentThread]);
                    }];
                }];
            }];
        }];
    }];
}

-(void)actionHellow {
    NSLog(@"hellow");
}
    
@end
