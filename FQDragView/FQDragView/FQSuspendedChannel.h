//
//  FQSuspendedChannel.h
//  FQDragView
//
//  Created by yasuo on 2020/1/19.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQDragView.h"
#import "FQSuspensionTransition.h"
NS_ASSUME_NONNULL_BEGIN

#define FQSCInstance [FQSuspendedChannel sharedInstance]

@interface FQSuspendedChannel : NSObject

/** 单例对象 */
+(instancetype)sharedInstance;

/** 主窗口，浮窗的载体（可自定义 默认为[UIApplication sharedApplication].keyWindow） */
@property (nonatomic, strong) UIWindow *window;
/** 绑定的NavigationController 成为其及interactivePopGestureRecognizer的代理 */
@property (nonatomic, strong) UINavigationController *navCentr;

/** 当前浮窗（为nil时移除 或自行移除） */
@property (nonatomic, strong) FQDragView *suspensionView;

/**
 闭合浮窗的动画时间
 */
@property(nonatomic,assign)NSTimeInterval spreadDuring;
/** 展开浮窗的动画的时间 */
@property(nonatomic,assign)NSTimeInterval shrinkDuring;

/** 浮窗内item的边距 */
@property (nonatomic, assign, readonly) CGFloat itemDistance;

/** 展开/闭合/创建浮窗时是否有提示音，默认为NO */
@property (nonatomic, assign) BOOL canPlaySound;
/**
 * 自定义浮窗提示音的block
 - 默认展开为系统id为1397的提示音（低版本没有该铃声）
 - 默认闭合为系统id为1396的提示音（低版本没有该铃声）
 */
@property (nonatomic, copy) void (^playSpreadSoundBlock)(void); // 展开浮窗
@property (nonatomic, copy) void (^playShrinkSoundBlock)(void); // 创建/闭合浮窗
/**
 转场时的临时视图插入
 @param transitionView 添加的view
 */
- (void)insertTransitionView:(UIView *)transitionView;
@end

NS_ASSUME_NONNULL_END
