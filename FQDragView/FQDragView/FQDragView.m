//
//  FQDragView.m
//  FQDragView
//
//  Created by yasuo on 2020/1/17.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import "FQDragView.h"
#import "FQSuspendedChannel.h"

@interface FQDragView()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic, weak) UIVisualEffectView *effectView;
@property (nonatomic, weak) CAShapeLayer *maskLayer;
@end

@implementation FQDragView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefault];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefault];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.freeRect.origin.x!=0||self.freeRect.origin.y!=0||self.freeRect.size.height!=0||self.freeRect.size.width!=0) {
        //设置了freeRect--活动范围
    }else{
        //没有设置freeRect--活动范围，则设置默认的活动范围为父视图的frame
        self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    }
    self.dragButton.frame = (CGRect){CGPointZero,self.bounds.size};
}

-(void)setDefault{
    self.dragEnable = true;
    self.isKeepBounds = NO;
    self.backgroundColor = [UIColor lightGrayColor];
    //点击
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
    [self addGestureRecognizer:singleTap];
    self.userInteractionEnabled = YES;
    //长按
    UILongPressGestureRecognizer * longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTapDragView:)];
    [self addGestureRecognizer:longTap];
    //移动
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDragAction:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
}

// MARK: - 操作事件
-(void)clickDragView{
    if (self.clickDragViewBlock) {
        self.clickDragViewBlock(self);
    }
}

-(void)longTapDragView:(UILongPressGestureRecognizer*)longPress{
    //防止多次触发
    if (longPress.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    if(self.longTapDragViewBlock){
        self.longTapDragViewBlock(self);
    }
}

-(void)panDragAction:(UIPanGestureRecognizer *)pan{
    if(self.dragEnable==NO)return;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan://开始拖动
            if (self.beginDragBlock) {
                self.beginDragBlock(self);
            }
        //注意完成移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self];
            break;
            
        case UIGestureRecognizerStateChanged:{//拖动中
            //计算位移 = 当前位置 - 起始位置
            if (self.dragingBlock) {
                self.dragingBlock(self);
            }
            CGPoint point = [pan translationInView:self];
            float distace_x;
            float distace_y;
            switch (self.dragDirection) {
                case FQDragDirectionAny:
                    distace_x = point.x - self.startPoint.x;
                    distace_y = point.y - self.startPoint.y;
                    break;
                case FQDragDirectionHorizontal:
                    distace_x = point.x - self.startPoint.x;
                    distace_y = 0;
                    break;
                case FQDragDirectionVertical:
                    distace_x = 0;
                    distace_y = point.y - self.startPoint.y;
                    break;
                default:
                    distace_x = point.x - self.startPoint.x;
                    distace_y = point.y - self.startPoint.y;
                    break;
            }
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + distace_x, self.center.y + distace_y);
            //移动view
            self.center = newCenter;
            //  注意完成上述移动后，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
            
        case UIGestureRecognizerStateEnded:{//拖动结束
            [self keepBounds];
            if (self.endDragBlock) {
                self.endDragBlock(self);
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)shrinkSuspensionViewAnimationWithComplete:(void (^)(void))complete {
    
    self.userInteractionEnabled = NO;
    
    CGRect frame = self.layer.presentationLayer ? self.layer.presentationLayer.frame : self.layer.frame;
    [self.layer removeAllAnimations];
    self.layer.transform = CATransform3DIdentity;
    self.layer.zPosition = 0;
    BOOL isHideNavigationBar = false;
    if (isHideNavigationBar) {
        self.frame = (self.superview && self.superview != FQSCInstance.window) ? [self.superview convertRect:frame toView:FQSCInstance.window] : frame;
        [FQSCInstance insertTransitionView:self];
    } else {
        self.frame = (self.superview && self.superview != FQSCInstance.navCentr.view) ? [self.superview convertRect:frame toView:FQSCInstance.navCentr.view] : frame;
        [FQSCInstance.navCentr.view insertSubview:self belowSubview:FQSCInstance.navCentr.navigationBar];
    }
    
//    [self addSubview:self.targetVC.view];
    [self createEffectView];
//    [self setupLogo];
//    self.logoView.layer.opacity = 0;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0.1].CGPath;
    [self.layer addSublayer:maskLayer];
    self.maskLayer = maskLayer;
    self.layer.mask = self.maskLayer;
    
    NSTimeInterval duration = 0.375;
    
//    [FQSCInstance playSoundForSpread:NO delay:duration * 0.5];
    
    UIBezierPath *toPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, frame.size.width, frame.size.height) cornerRadius:frame.size.width * 0.5];
    UIBezierPath *toPath2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, (frame.size.height - frame.size.width) * 0.5, frame.size.width, frame.size.width) cornerRadius:frame.size.width * 0.5];
    CAKeyframeAnimation *kfAnim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    kfAnim.values = @[(id)self.maskLayer.path, (id)toPath1.CGPath, (id)toPath2.CGPath];
    kfAnim.keyTimes = @[@0, @0.5, @(1)];
    kfAnim.duration = duration;
    kfAnim.beginTime = CACurrentMediaTime();
    kfAnim.fillMode = kCAFillModeForwards;
    kfAnim.removedOnCompletion = NO;
    [self.maskLayer addAnimation:kfAnim forKey:@"path"];
    
    CGFloat toScale = FQSCInstance.suspensionView.frame.size.width / frame.size.width;
    CGPoint toPos = CGPointMake(CGRectGetMidX(FQSCInstance.suspensionView.frame), CGRectGetMidY(FQSCInstance.suspensionView.frame));
    CATransform3D transform = self.layer.transform;
    transform = CATransform3DMakeTranslation(toPos.x - self.layer.position.x, toPos.y - self.layer.position.y, 0);
    transform = CATransform3DScale(transform, toScale, toScale, 1);
    
    [UIView animateWithDuration:duration delay:0 options:kNilOptions animations:^{
        FQSCInstance.suspensionView.alpha = 0;
//        self.targetVC.view.layer.opacity = 0;
//        self.logoView.layer.opacity = 1;
        self.layer.transform = transform;
    } completion:^(BOOL finished) {
        FQSCInstance.suspensionView = self;
        
        [self.maskLayer removeFromSuperlayer];
//        [self.targetVC.view removeFromSuperview];
//        self.targetVC.view.layer.opacity = 1;
        
        self.layer.transform = CATransform3DIdentity;
        self.layer.cornerRadius = FQSCInstance.suspensionView.frame.size.width * 0.5;
        self.layer.masksToBounds = YES;
        self.layer.mask = nil;
        self.frame = FQSCInstance.suspensionView.frame;
        
        self.effectView.frame = CGRectInset(self.bounds, -1, -1);
        
//        if (self.logoView) {
//            CGFloat logoMargin = self.suspensionLogoMargin;
//            self.logoView.frame = CGRectInset(self.bounds, logoMargin, logoMargin);
//            self.logoView.layer.cornerRadius = self.logoView.frame.size.height * 0.5;
//        }
        
        self.userInteractionEnabled = YES;
        !complete ? : complete();
    }];
}

- (void)createEffectView {
    if (self.effectView) return;
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.frame = CGRectInset(self.bounds, -1, -1);
    [self insertSubview:effectView atIndex:0];
    self.effectView = effectView;
}

//黏贴边界效果
- (void)keepBounds{
    //中心点判断
    float centerX = self.freeRect.origin.x+(self.freeRect.size.width - self.frame.size.width)/2;
    CGRect rect = self.frame;
    if (self.isKeepBounds==NO) {//没有黏贴边界的效果
        if (self.frame.origin.x < self.freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else if(self.freeRect.origin.x+self.freeRect.size.width < self.frame.origin.x+self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x+self.freeRect.size.width-self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }else if(self.isKeepBounds==YES){//自动粘边
        if (self.frame.origin.x< centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }
    
    if (self.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
    } else if(self.freeRect.origin.y+self.freeRect.size.height< self.frame.origin.y+self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
    }
}

// MARK: - 懒加载
-(UIButton *)dragButton{
    if (_dragButton==nil) {
        _dragButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dragButton.userInteractionEnabled = NO;
    }
    return _dragButton;
}

@end
