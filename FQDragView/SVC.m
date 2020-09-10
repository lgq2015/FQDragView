//
//  SVC.m
//  FQDragView
//
//  Created by yasuo on 2020/1/19.
//  Copyright © 2020 TeacherFu. All rights reserved.
//

#import "SVC.h"

@interface SVC ()
@property(nonatomic,strong)UIButton * nexBtn;
@property(nonatomic,strong)UIButton * popBtn;
@end

@implementation SVC

- (void)viewDidLoad {
//    self.navigationController.navigationBarHidden = true;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    _nexBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nexBtn.frame = CGRectMake(100, 100, 100, 100);
    _nexBtn.backgroundColor = [UIColor blueColor];
    [_nexBtn addTarget:self action:@selector(afterClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nexBtn];
    _nexBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nexBtn.frame = CGRectMake(200, 200, 100, 100);
    _nexBtn.backgroundColor = [UIColor blueColor];
    [_nexBtn addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nexBtn];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = false;
}

-(void)afterClick{
    
    [self presentViewController:[SVC new] animated:true completion:^{
    
    }];
}

-(void)popAction{
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
    [self.navigationController popViewControllerAnimated:true];
}

@end
