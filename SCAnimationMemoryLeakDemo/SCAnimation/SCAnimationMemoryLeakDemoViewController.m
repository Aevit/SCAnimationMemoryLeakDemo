//
//  SCAnimationMemoryLeakDemoViewController.m
//  SCAnimationMemoryLeakDemo
//
//  Created by aevit on 2018/7/2.
//  Copyright © 2018年 arvit. All rights reserved.
//

#import "SCAnimationMemoryLeakDemoViewController.h"

#define SCWeakSelf(type) __weak typeof(type) weak##type = type;
#define SCStrongSelf(type) __strong typeof(type) type = weak##type;

#define kBaseAnimationKey   @"kBaseAnimationKey"
#define kKeyAnimationKey    @"kKeyAnimationKey"

static CGFloat moveDuration = 2;
static CGFloat pauseDuration = 2;
static CGFloat moveLength = 375;

@interface SCAnimationMemoryLeakDemoViewController () <CAAnimationDelegate>

@property (nonatomic, strong) UIView *baseAniMoveView;

@end

@implementation SCAnimationMemoryLeakDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _removeAnimationDelegate = YES;
    [self.view addSubview:self.baseAniMoveView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tips" message:@"call dealloc" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    NSLog(@"test hit dealloc");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.type == SCDemoTypeSolutionKeyFrameAnimation) {
        [self startKeyAnimation];
        
    } else {
        [self startBaseAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 注意! 这里要移除，不然如果有设置了 animation 的 delegate，因为这个 delegate 为 strong 的，所以不移除就会造成内存泄露了
    if (_removeAnimationDelegate) {
        [self.baseAniMoveView.layer removeAllAnimations];
    }
    
    if (self.type == SCDemoTypeSolutionCancelPerfrom) {
        // performSelector 问题的解决方案1
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBaseAnimation) object:nil];
    }
}

#pragma mark - animations
- (void)startBaseAnimation
{
    if (!_baseAniMoveView) return;
    
    self.navigationItem.title = @"动画进行中...";
    
    [self.baseAniMoveView.layer removeAllAnimations];
    
    self.baseAniMoveView.hidden = NO;
    CABasicAnimation * baseAni = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint leftStarPosition = self.baseAniMoveView.center;
    baseAni.fromValue = [NSValue valueWithCGPoint:self.baseAniMoveView.center];
    baseAni.toValue = [NSValue valueWithCGPoint:CGPointMake(leftStarPosition.x + moveLength, leftStarPosition.y)];
    baseAni.duration = moveDuration;
    baseAni.removedOnCompletion = NO;
    baseAni.delegate = self;
    baseAni.fillMode = kCAFillModeForwards;
    
    [self.baseAniMoveView.layer addAnimation:baseAni forKey:kBaseAnimationKey];
}

- (void)startKeyAnimation
{
    if (!_baseAniMoveView) return;
    
    [self.baseAniMoveView.layer removeAllAnimations];
    
    // 显示 view
    CAKeyframeAnimation *showAni = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    showAni.duration = 0;
    showAni.values = @[@1, @1];
    
    // 移动 view
    CGPoint leftStarPosition = self.baseAniMoveView.center;
    CAKeyframeAnimation *baseAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    baseAni.duration = moveDuration;
    NSValue *fromValue =  [NSValue valueWithCGPoint:self.baseAniMoveView.center];
    NSValue *toValue = [NSValue valueWithCGPoint:CGPointMake(leftStarPosition.x + moveLength, leftStarPosition.y)];
    baseAni.values = @[fromValue, toValue];
    baseAni.removedOnCompletion = NO;
    baseAni.fillMode = kCAFillModeForwards;
    
    // 隐藏 view
    CAKeyframeAnimation *hideAni = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    hideAni.duration = pauseDuration;
    hideAni.values = @[@0, @0];
    hideAni.beginTime = CACurrentMediaTime() + moveDuration; // important!
    
    // 动画组
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[showAni, baseAni, hideAni];
    group.repeatCount = FLT_MAX;
    group.duration = moveDuration + pauseDuration;
    
    // 添加动画
    [self.baseAniMoveView.layer addAnimation:group forKey:kKeyAnimationKey];
}

#pragma mark - animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.navigationItem.title = flag ? @"动画正常完成（点击返回）" : @"动画未完成";
    NSLog(@"test hit animation stop, finished: %d", flag);
    if (flag && _baseAniMoveView) {
        [self.baseAniMoveView.layer removeAllAnimations];
        self.baseAniMoveView.hidden = YES;
        
        if (self.type == SCDemoTypeMemoryLeak) {
            // 以下做法会造成内存泄露，因为 performSelector 内部有一个 timer，timer 会持有 self，造成循环引用，所以 dealloc 就一直不调用了
            // performSelector 问题的解决方式有两个：1、在 viewWillDisappear 里调用 cancel 方法   2、改用下面的 dispatch_after
            [self performSelector:@selector(startBaseAnimation) withObject:nil afterDelay:pauseDuration];
            
        } else if (self.type == SCDemoTypeSolutionDispatchAfter) {
            // performSelector 问题的解决方案2
            SCWeakSelf(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pauseDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                SCStrongSelf(self);
                if (!self) return;
                [self startBaseAnimation];
            });
        }
    }
}

#pragma mark - properties
- (UIView *)baseAniMoveView
{
    if (!_baseAniMoveView) {
        _baseAniMoveView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 80, 40)];
        _baseAniMoveView.backgroundColor = [UIColor lightGrayColor];
    }
    return _baseAniMoveView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
