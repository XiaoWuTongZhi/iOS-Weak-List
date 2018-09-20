//
//  TestWeakViewController.m
//  TestService
//
//  Created by wyh on 2018/9/19.
//  Copyright © 2018年 wyh. All rights reserved.
//

#import "TestWeakViewController.h"
#import "TestDemoService.h"

@interface TestWeakViewController () <TestServiceProtocol>

@end

@implementation TestWeakViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"weak";
    self.view.backgroundColor = [UIColor whiteColor];
    
    /*
    TestServiceWeakTypeNSValue ,
    TestServiceWeakTypeNSBlock ,
    TestServiceWeakTypeNSPointerArray ,
    TestServiceWeakTypeNSHashTable ,
    TestServiceWeakTypeNSMapTable,
    */
    [TestDemoService registObserver:self type:(TestServiceWeakTypeNSPointerArray)];
    
    
}

- (void)dealloc {
    NSLog(@"我%@销毁了",self);
}

#pragma mark - Protocol

- (void)testService:(TestDemoService *)service type:(TestServiceWeakType)type {
    NSString *typeString = nil;
    switch (type) {
        case TestServiceWeakTypeNSValue:
        {
            typeString = @"TestServiceWeakTypeNSValue";
        }
            break;
        case TestServiceWeakTypeNSBlock:
        {
            typeString = @"TestServiceWeakTypeNSBlock";
        }
            break;
        case TestServiceWeakTypeNSPointerArray:
        {
            typeString = @"TestServiceWeakTypeNSPointerArray";
        }
            break;
        case TestServiceWeakTypeNSHashTable:
        {
            typeString = @"TestServiceWeakTypeNSHashTable";
        }
            break;
        case TestServiceWeakTypeNSMapTable:
        {
            typeString = @"TestServiceWeakTypeNSMapTable";
        }
            break;
        default:
            break;
    }
    NSLog(@"weak obj by %@",typeString);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
