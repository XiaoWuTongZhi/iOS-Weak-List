//
//  ViewController.m
//  TestHash
//
//  Created by wyh on 2018/9/20.
//  Copyright © 2018年 wyh. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Person *pa = [[Person alloc]init];
    pa.name = @"Michael";
    pa.birthday = @"1987";
    
    Person *pb = [[Person alloc]init];
    pb.name = @"Michael";
    pb.birthday = @"1987";
    
//    NSMutableSet *set = [NSMutableSet set];
//    [set addObject:pa];
//    [set addObject:pb];
//    NSLog(@"set count = %ld", set.count);
    
    
    
//   NSMapTableObjectPointerPersonality | NSPointerFunctionsObjectPersonality
    
    NSMapTable *table = [[NSMapTable alloc]initWithKeyOptions:(NSPointerFunctionsObjectPersonality) valueOptions:(NSPointerFunctionsObjectPersonality) capacity:10];
    [table setObject:@"asd" forKey:pa];
    [table setObject:@"asdasd" forKey:pb];
    NSLog(@"table:%@",table);
    
    
//    if ([pa isEqual:pb]){
//
//        NSLog(@"equal");
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
