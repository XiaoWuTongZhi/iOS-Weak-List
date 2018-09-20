//
//  TestDemoService.h
//  TestBlock
//
//  Created by wyh on 2018/9/19.
//  Copyright © 2018年 wyh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TestServiceWeakType) {
    
    TestServiceWeakTypeNSValue ,
    TestServiceWeakTypeNSBlock ,
    TestServiceWeakTypeNSPointerArray ,
    TestServiceWeakTypeNSHashTable ,
    TestServiceWeakTypeNSMapTable,
};

@class TestDemoService;

@protocol TestServiceProtocol <NSObject>

- (void)testService:(TestDemoService *)service type:(TestServiceWeakType)type;

@end

@interface TestDemoService : NSObject

+ (instancetype)service;

+ (void)registObserver:(id<TestServiceProtocol>)observer type:(TestServiceWeakType)type;


+ (void)registObserverByBlock:(id<TestServiceProtocol>)observer;

+ (void)startAllTasks;


@end
