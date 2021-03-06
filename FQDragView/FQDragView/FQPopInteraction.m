//
//  FQPopInteraction.m
//  FQDragView
//
//  Created by yasuo on 2020/1/20.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import "FQPopInteraction.h"

@interface FQPopInteraction()
{
    CGFloat _persent;
    CGFloat _linkValue;
    BOOL _isToFinish;
}
@property (nonatomic, strong) CADisplayLink * displayLink;
@end

@implementation FQPopInteraction

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefault];
    }
    return self;
}

-(void)setDefault{
    self.edgeLeftPanGR = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgeLeftPanHandle:)];
    self.edgeLeftPanGR.edges = UIRectEdgeLeft;
    _linkValue = 1.0 / 24.0;
}

- (void)edgeLeftPanHandle:(UIScreenEdgePanGestureRecognizer *)edgeLeftPanGR {
    UIView *referenceView = edgeLeftPanGR.view;
    CGPoint velocity = [edgeLeftPanGR velocityInView:referenceView];
    CGPoint transition = [edgeLeftPanGR translationInView:referenceView];
    
    // 手势百分比
    _persent = transition.x / referenceView.bounds.size.width;
    if (_persent < 0) _persent = 0;
    if (_persent > 1) _persent = 1;
    
    if (edgeLeftPanGR.state == UIGestureRecognizerStateBegan) {
        
        self.interaction = YES;
        !self.panBegan ? : self.panBegan(edgeLeftPanGR);
        
        [self updateInteractiveTransition:_persent];
        !self.panChanged ? : self.panChanged(_persent, edgeLeftPanGR);
        
    } else if (edgeLeftPanGR.state == UIGestureRecognizerStateChanged) {
        
        [self updateInteractiveTransition:_persent];
        !self.panChanged ? : self.panChanged(_persent, edgeLeftPanGR);
        
    } else if (edgeLeftPanGR.state == UIGestureRecognizerStateEnded ||
               edgeLeftPanGR.state == UIGestureRecognizerStateCancelled ||
               edgeLeftPanGR.state == UIGestureRecognizerStateFailed) {
        
        self.interaction = NO;
        BOOL isFast = velocity.x > 500;
        
        _isToFinish = isFast || _persent > 0.5;
        !self.panWillEnded ? : self.panWillEnded(_isToFinish, edgeLeftPanGR);
        
        if (isFast) {
            [self finishInteractiveTransition];
            !self.panEnded ? : self.panEnded(_isToFinish, self.edgeLeftPanGR);
        } else {
            [self addLink];
        }
    }
}

-(void)addLink{
    [self removeLink];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkHandle)];
}

- (void)removeLink {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)linkHandle {
    if (_isToFinish) {
        _persent += _linkValue;
        if (_persent < 1.0) {
            [self updateInteractiveTransition:_persent];
            !self.panChanged ? : self.panChanged(_persent, self.edgeLeftPanGR);
        } else {
            _persent = 1.0;
            [self removeLink];
            [self finishInteractiveTransition];
            !self.panEnded ? : self.panEnded(YES, self.edgeLeftPanGR);
        }
    } else {
        _persent -= _linkValue;
        if (_persent > 0) {
            [self updateInteractiveTransition:_persent];
            !self.panChanged ? : self.panChanged(_persent, self.edgeLeftPanGR);
        } else {
            _persent = 0;
            [self removeLink];
            [self cancelInteractiveTransition];
            !self.panEnded ? : self.panEnded(NO, self.edgeLeftPanGR);
        }
    }
}

@end
