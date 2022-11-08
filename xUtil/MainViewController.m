
#import "MainViewController.h"
#import "xUtil.h"
#import "xUI.h"
#import "Masonry.h"
#import "ReactiveObjC.h"
#import "CustomLabel.h"


@interface MainViewController () {
    BOOL _isLoading;
    int _indicater;
    RACSubject *_letters;
    RACSubject *_numbers;
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
    CustomLabel *label = [[CustomLabel alloc] init];
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

-(void)actionHellow{
    NSLog(@"hellow");
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

@end
