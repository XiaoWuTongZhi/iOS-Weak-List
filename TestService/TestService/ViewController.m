//
//  ViewController.m
//  TestDemoService
//
//  Created by wyh on 2018/9/19.
//  Copyright © 2018年 wyh. All rights reserved.
//

#import "ViewController.h"
#import "TestDemoService.h"
#import "TestWeakViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Test";
    
    [self configUI];
}

- (void)configUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //keywindow
    UIButton *circle = ({
        circle = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [circle setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [circle setTitle:@"TASK" forState:(UIControlStateNormal)];
        circle.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*0.5-25, 100, 50, 50);
        circle.backgroundColor = [UIColor redColor];
        circle.layer.cornerRadius = 25.f;
        circle.layer.masksToBounds = YES;
        [circle addTarget:self action:@selector(startTask:) forControlEvents:(UIControlEventTouchUpInside)];
        [[UIApplication sharedApplication].delegate.window addSubview:circle];
        circle;
    });
    
    UIButton *weak = ({
        weak = [UIButton buttonWithType:(UIButtonTypeCustom)];
        weak.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*0.5-75, [UIScreen mainScreen].bounds.size.height - 200, 150, 30);
        [weak addTarget:self action:@selector(pushWeak:) forControlEvents:(UIControlEventTouchUpInside)];
        [weak setTitle:@"push weak" forState:(UIControlStateNormal)];
        [weak setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
        [self.view addSubview:weak];
        weak;
    });
    
    
}

#pragma mark - Methods

- (void)pushWeak:(id)sender {
    TestWeakViewController *weakVC = [TestWeakViewController new];
    [self.navigationController pushViewController:weakVC animated:YES];
}



- (void)startTask:(id)sender {
    
    [TestDemoService startAllTasks];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
