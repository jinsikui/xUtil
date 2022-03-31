
#import "MainViewController.h"
#import "xUtil.h"
#import "xUI.h"
#import "Masonry.h"


@interface MainViewController ()
@property(nonatomic,strong) UIScrollView *scroll;
@property (nonatomic, assign) CGFloat currentY;

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

@end
