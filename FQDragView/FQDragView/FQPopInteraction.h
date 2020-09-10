//
//  FQPopInteraction.h
//  FQDragView
//
//  Created by yasuo on 2020/1/20.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FQPopInteraction : UIPercentDrivenInteractiveTransition 
@property (nonatomic, assign) BOOL interaction;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgeLeftPanGR;
@property (nonatomic, copy) void(^panBegan)(UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);
@property (nonatomic, copy) void(^panChanged)(CGFloat persent,UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);
@property (nonatomic, copy) void(^panWillEnded)(BOOL isFinish,UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);
@property (nonatomic, copy) void(^panEnded)(BOOL isFinish,UIScreenEdgePanGestureRecognizer *edgeLeftPanGR);
@end

NS_ASSUME_NONNULL_END
