//
//  ViewController.m
//  FQDragView
//
//  Created by yasuo on 2020/1/17.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import "ViewController.h"
#import "FQDragView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"可拖曳的View";
    [super viewDidLoad];
    
    
    FQDragView *redView = [[FQDragView alloc]initWithFrame:CGRectMake(20, 64+20, 200, 200)];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, redView.frame.size.width, 60)];
    label.text = @"橙色view被限制在红色view中，出不来了!";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [redView addSubview:label];
    
    FQDragView *orangeView = [[FQDragView alloc] initWithFrame:CGRectMake(0, 0 , 70, 70)];
    orangeView.dragDirection = FQDragDirectionVertical;
    orangeView.dragButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [orangeView.dragButton setTitle:@"可拖曳" forState:UIControlStateNormal];
    orangeView.backgroundColor = [UIColor orangeColor];
    [redView addSubview:orangeView];
    orangeView.clickDragViewBlock = ^(FQDragView *dragView){
        NSLog(@"橙色view被点击了");
        dragView.dragEnable = !dragView.dragEnable;
        if (dragView.dragEnable) {
            [dragView.dragButton setTitle:@"可拖曳" forState:UIControlStateNormal];
        }else{
            [dragView.dragButton setTitle:@"不可拖曳" forState:UIControlStateNormal];
        }
        
    };
    orangeView.longTapDragViewBlock = ^(FQDragView * _Nonnull dragView) {
        NSLog(@"橙色view被长按了");
        dragView.dragEnable = !dragView.dragEnable;
        if (dragView.dragEnable) {
            [dragView.dragButton setTitle:@"可拖曳" forState:UIControlStateNormal];
        }else{
            [dragView.dragButton setTitle:@"不可拖曳" forState:UIControlStateNormal];
        }
    };
    
    //    orangeView.EndDragBlock = ^(FQDragView *dragView) {
    //        [UIView animateWithDuration:0.5 animations:^{
    //            dragView.frame = CGRectMake(0, 0 , 70, 70);
    //        }];
    //    };
    
    
    
    ///初始化可以拖曳的view
    FQDragView *logoView = [[FQDragView alloc] initWithFrame:CGRectMake(0, 0 , 70, 70)];
    logoView.layer.cornerRadius = 14;
    logoView.isKeepBounds = YES;
    //设置显示图片
    [logoView.dragButton setBackgroundImage:[UIImage imageNamed:@"logo1024"] forState:UIControlStateNormal];
    
    
    [logoView setBackgroundColor:[UIColor redColor]];
    [[UIApplication sharedApplication].keyWindow addSubview:logoView];
    //限定logoView的活动范围
    logoView.center = self.view.center;
    logoView.clickDragViewBlock = ^(FQDragView *dragView){
    
    };
}


@end
