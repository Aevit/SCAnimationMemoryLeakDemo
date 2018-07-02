//
//  ViewController.m
//  SCAnimationMemoryLeakDemo
//
//  Created by aevit on 2018/7/2.
//  Copyright © 2018年 arvit. All rights reserved.
//

#import "ViewController.h"
#import "SCAnimationMemoryLeakDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leakBtnPressed:(id)sender
{
    SCAnimationMemoryLeakDemoViewController *con = [[SCAnimationMemoryLeakDemoViewController alloc] init];
    con.type = SCDemoTypeMemoryLeak; // 在动画完成后，刚好点击了返回就会泄露（可注意控制台信息，一触发动画完成的回调，就点击返回试试）
//    con.removeAnimationDelegate = NO; // 为 NO 表示不移除动画的 delegate，如果不移除的话，还是会造成内存泄露的
    [self.navigationController pushViewController:con animated:YES];
}

- (IBAction)dispatchAfterBtnPressed:(id)sender
{
    SCAnimationMemoryLeakDemoViewController *con = [[SCAnimationMemoryLeakDemoViewController alloc] init];
    con.type = SCDemoTypeSolutionDispatchAfter;
//    con.removeAnimationDelegate = NO; // 为 NO 表示不移除动画的 delegate，如果不移除的话，还是会造成内存泄露的
    [self.navigationController pushViewController:con animated:YES];
}

- (IBAction)cancelPerfromBtnPressed:(id)sender
{
    SCAnimationMemoryLeakDemoViewController *con = [[SCAnimationMemoryLeakDemoViewController alloc] init];
    con.type = SCDemoTypeSolutionCancelPerfrom;
//    con.removeAnimationDelegate = NO; // 为 NO 表示不移除动画的 delegate，如果不移除的话，还是会造成内存泄露的
    [self.navigationController pushViewController:con animated:YES];
}

- (IBAction)keyFrameAnimationBtnPressed:(id)sender
{
    // 这种方式，因为没有设置 animation 的 delegate，所以不移除动画也不会造成内存泄露。
    // 同样也不用使用 performSelector，所以也不会造成循环引用。
    SCAnimationMemoryLeakDemoViewController *con = [[SCAnimationMemoryLeakDemoViewController alloc] init];
    con.type = SCDemoTypeSolutionKeyFrameAnimation;
    [self.navigationController pushViewController:con animated:YES];
}

@end
