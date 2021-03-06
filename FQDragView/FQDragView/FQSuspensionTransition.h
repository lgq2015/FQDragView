//
//  FQSuspensionTransition.h
//  FQDragView
//
//  Created by yasuo on 2020/1/19.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,FQSuspensionTransitionType) {
    FQSuspensionTransitionTypePop,      // 高仿系统
    FQSuspensionTransitionTypeSpread,   // 展开浮窗
    FQSuspensionTransitionTypeShrink    // 闭合浮窗
};

@class FQDragView;

@interface FQSuspensionTransition : NSObject<UIViewControllerAnimatedTransitioning>
@property(nonatomic,assign)FQSuspensionTransitionType transitionType;
@property(nonatomic,strong)FQDragView * suspensionView;

/**
 初始化
 @param transitionType 转场方式
 */
- (instancetype)initWithTransitionType:(FQSuspensionTransitionType)transitionType;

/** 是否要创建浮窗 */
@property (nonatomic, assign) BOOL isShrinkSuspension;

/**
闭合浮窗的动画时间
 */
@property(nonatomic,assign)NSTimeInterval spreadDuring;
/** 展开浮窗的动画的时间 */
@property(nonatomic,assign)NSTimeInterval shrinkDuring;

/** 高仿的系统pop动画
* @param isInteraction 是否手势操控
*/
+(FQSuspensionTransition *)popTransitionWithIsInteraction:(BOOL)isInteraction;

/// 展开浮窗的动画
+ (FQSuspensionTransition *)spreadTransitionWithSuspensionView:(FQDragView *)suspensionView;

/// 闭合浮窗的动画
+ (FQSuspensionTransition *)shrinkTransitionWithSuspensionView:(FQDragView *)suspensionView;

/** 转场结束 */
- (void)transitionCompletion;
@end

NS_ASSUME_NONNULL_END
