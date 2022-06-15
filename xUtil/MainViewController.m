
#import "MainViewController.h"
#import "xUtil.h"
#import "xUI.h"
#import "Masonry.h"
#import "ReactiveObjC.h"


@interface MainViewController ()
@property(nonatomic,strong) UIScrollView *scroll;
@property (nonatomic, assign) CGFloat currentY;
@property(nonatomic,strong) RACSignal *signal;
@property(nonatomic,strong) RACSubject *subject;
@end

@implementation MainViewController

#pragma mark - life circle
- (instancetype)init {
    if (self = [super init]) {
        self.currentY = 30;
    }
    return self;
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

-(void)actionHellow{
    NSLog(@"hellow");
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
    
    self.subject = [RACReplaySubject subject];
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

@end
