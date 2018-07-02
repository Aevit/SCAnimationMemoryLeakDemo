//
//  SCAnimationMemoryLeakDemoViewController.h
//  SCAnimationMemoryLeakDemo
//
//  Created by aevit on 2018/7/2.
//  Copyright © 2018年 arvit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SCDemoType) {
    SCDemoTypeMemoryLeak = 0,
    SCDemoTypeSolutionDispatchAfter = 1,
    SCDemoTypeSolutionCancelPerfrom = 2,
    SCDemoTypeSolutionKeyFrameAnimation = 3
};

@interface SCAnimationMemoryLeakDemoViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *tipLabel;

@property (nonatomic, assign) SCDemoType type;

/**
 为 NO 表示不移除动画的 delegate，如果不移除的话，还是会造成内存泄露的
 */
@property (nonatomic, assign) BOOL removeAnimationDelegate;

@end
