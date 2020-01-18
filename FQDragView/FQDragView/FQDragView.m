//
//  FQDragView.m
//  FQDragView
//
//  Created by yasuo on 2020/1/17.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import "FQDragView.h"

@interface FQDragView()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,assign) CGPoint startPoint;
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
    UILongPressGestureRecognizer * longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTapDragView)];
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

-(void)longTapDragView{
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
