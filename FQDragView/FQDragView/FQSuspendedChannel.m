//
//  FQSuspendedChannel.m
//  FQDragView
//
//  Created by yasuo on 2020/1/19.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import "FQSuspendedChannel.h"
#import "FQSuspensionTransition.h"

@interface FQSuspendedChannel()<NSCopying,UINavigationControllerDelegate,UIGestureRecognizerDelegate>
/** 动画配置 */
@property(nonatomic,strong)FQSuspensionTransition * suspensionTransition;
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
// MARK: - UINavigationControllerDelegate代理
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    BOOL isPush = operation == UINavigationControllerOperationPush;
    self.suspensionTransition = nil;
    if(isPush){
        self.suspensionTransition = [FQSuspensionTransition spreadTransitionWithSuspensionView:self.suspensionView];
        self.suspensionTransition.spreadDuring = self.spreadDuring;
    }else{
        self.suspensionTransition = [FQSuspensionTransition shrinkTransitionWithSuspensionView:self.suspensionView];
        self.suspensionTransition.shrinkDuring = self.shrinkDuring;
    }
    return self.suspensionTransition;
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
    }
    _navCentr = navCentr;
    
    navCentr.delegate = self;
    navCentr.interactivePopGestureRecognizer.delegate = self;
}



@end
