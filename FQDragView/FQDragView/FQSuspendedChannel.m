//
//  FQSuspendedChannel.m
//  FQDragView
//
//  Created by yasuo on 2020/1/19.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import "FQSuspendedChannel.h"
#import "FQSuspensionTransition.h"
#import "FQPopInteraction.h"

@interface FQSuspendedChannel()<NSCopying,UINavigationControllerDelegate,UIGestureRecognizerDelegate>
/** 动画配置 */
@property(nonatomic,strong)FQSuspensionTransition * suspensionTransition;
/** 返回手势 */
@property (nonatomic, strong) FQPopInteraction * popInteraction;
/** 是否从dragView跳转 */
@property (nonatomic, assign) BOOL isFromSpreadSuspensionView;
@end

static FQSuspendedChannel * _sharedInstance = nil;

@implementation FQSuspendedChannel

// MARK: - 初始化
+ (instancetype)sharedInstance {
    if(_sharedInstance == nil) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [super allocWithZone:zone];
        [_sharedInstance setDefault];
        [_sharedInstance setUpPopInteraction];
    });
    return _sharedInstance;
}

- (id)copyWithZone:(nullable NSZone *)zone{
    return [FQSuspendedChannel sharedInstance];
}

// MARK: - 配置
-(void)setDefault{
    _window = [UIApplication sharedApplication].keyWindow;
}

-(void)setUpPopInteraction{
    self.popInteraction = [[FQPopInteraction alloc] init];
    self.popInteraction.edgeLeftPanGR.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    
    self.popInteraction.panBegan = ^(UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.navCentr popViewControllerAnimated:YES];
    };
    
    self.popInteraction.panChanged = ^(CGFloat persent, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CGFloat kPersent = persent * 2.0;
        if (kPersent > 1) kPersent = 1;
        if (strongSelf.isFromSpreadSuspensionView) {
            strongSelf.suspensionView.alpha = kPersent;
        } else {

        }
    };
    
    self.popInteraction.panWillEnded = ^(BOOL isToFinish, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isFromSpreadSuspensionView) {
            if (isToFinish) {
                strongSelf.suspensionTransition.isShrinkSuspension = YES;
                
                    [strongSelf.suspensionTransition transitionCompletion];
            };
        }
    };
    
    self.popInteraction.panEnded = ^(BOOL isFinish, UIScreenEdgePanGestureRecognizer *edgeLeftPanGR) {
        if (!weakSelf) return;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.suspensionTransition.isShrinkSuspension) {
            [strongSelf.suspensionTransition transitionCompletion];
        }
        if (strongSelf.isFromSpreadSuspensionView) {
            strongSelf.suspensionView.alpha = isFinish ? 1 : 0;
            strongSelf.isFromSpreadSuspensionView = NO;
        }
    };
}

// MARK: - UINavigationControllerDelegate代理
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    BOOL isPush = operation == UINavigationControllerOperationPush;
    self.suspensionTransition = nil;
    if(isPush){
        self.suspensionTransition = [FQSuspensionTransition spreadTransitionWithSuspensionView:self.suspensionView];
        self.suspensionTransition.spreadDuring = self.spreadDuring;
    }else{
        if (!self.popInteraction.interaction) {
                self.suspensionTransition = [FQSuspensionTransition shrinkTransitionWithSuspensionView:self.suspensionView];
        }else{
            self.suspensionTransition = [FQSuspensionTransition popTransitionWithIsInteraction:self.popInteraction.interaction];
        }
    }
    return self.suspensionTransition;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    if ([animationController isKindOfClass:FQSuspensionTransition.class] && self.popInteraction.interaction) {
        return self.popInteraction;

    }
    return nil;
}

// MARK: - UIGestureRecognizerDelegate代理
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer == self.navCentr.interactivePopGestureRecognizer ||
//        gestureRecognizer == self.popInteraction.edgeLeftPanGR) {
//        if (self.navCentr.viewControllers.count <= 1) {
//            return NO;
//        }
//        if (gestureRecognizer == self.navCentr.interactivePopGestureRecognizer ) {
//            return NO;
//        }
//        if (gestureRecognizer == self.popInteraction.edgeLeftPanGR) {
//            return NO;
//        }
//    }
//    return YES;
//}

// MARK: - 转场时的临时视图插入
- (void)insertTransitionView:(UIView *)transitionView{
    if (_suspensionView && transitionView == _suspensionView) {
        [self.window addSubview:transitionView];
    }else {
        if (_suspensionView) {
            [self.window insertSubview:transitionView belowSubview:_suspensionView];
        } else {
            [self.window addSubview:transitionView];
        }
    }
}

// MARK: - 懒加载
- (void)setWindow:(UIWindow *)window{
    _window = window;
    [window addSubview:_suspensionView];
}

- (void)setSuspensionView:(FQDragView *)suspensionView{
    [_suspensionView removeFromSuperview];
    _suspensionView = suspensionView;
    if(_suspensionView){
        if(_suspensionView.superview != self.window){
            _suspensionView.frame = [_suspensionView.superview convertRect:_suspensionView.frame toView:self.window];
        }
        [self.window addSubview:_suspensionView];
        //点击
        _suspensionView.clickDragViewBlock = ^(FQDragView * _Nonnull dragView) {
            
        };
        //长按
        _suspensionView.longTapDragViewBlock = ^(FQDragView * _Nonnull dragView) {
            
        };
        //开始
        _suspensionView.beginDragBlock = ^(FQDragView * _Nonnull dragView) {
            
        };
        //拖动
        _suspensionView.dragingBlock = ^(FQDragView * _Nonnull dragView) {
            
        };
        //结束
        _suspensionView.endDragBlock = ^(FQDragView * _Nonnull dragView) {
            
        };
    }
    
    
}

- (void)setNavCentr:(UINavigationController *)navCentr{
    if (_navCentr && _navCentr == navCentr) return;
    if (_navCentr) {
        _navCentr.delegate = nil;
        _navCentr.interactivePopGestureRecognizer.delegate = self;
        [_navCentr.view removeGestureRecognizer:self.popInteraction.edgeLeftPanGR];
    }
    _navCentr = navCentr;
    
    navCentr.delegate = self;
    navCentr.interactivePopGestureRecognizer.delegate = self;
    [navCentr.view addGestureRecognizer:self.popInteraction.edgeLeftPanGR];
}


@end
