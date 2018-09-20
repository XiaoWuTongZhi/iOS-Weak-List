//
//  TestService.m
//  TestBlock
//
//  Created by wyh on 2018/9/19.
//  Copyright © 2018年 wyh. All rights reserved.
//

#import "TestDemoService.h"

typedef id(^WeakObjBlock)(void);

@interface TestDemoService ()

@property (nonatomic, strong) NSMutableArray *weakBlockArr;

@property (nonatomic, strong) NSMutableArray *weakValueArr;

@property (nonatomic, strong) NSPointerArray *pointerArray;

@property (nonatomic, strong) NSHashTable *hashTable;

@property (nonatomic, strong) NSMapTable *mapTable;

@end

@implementation TestDemoService

+ (instancetype)service {
    static dispatch_once_t onceToken;
    static TestDemoService *service = nil;
    dispatch_once(&onceToken, ^{
        service = [[TestDemoService alloc]init];
        [service initializeConfig];
    });
    return service;
}

- (void)initializeConfig {
    
    if (!_hashTable){
        _hashTable = [NSHashTable weakObjectsHashTable];
    }
    if (!_weakBlockArr) {
        _weakBlockArr = [NSMutableArray new];
    }
    if (!_weakValueArr) {
        _weakValueArr = [NSMutableArray new];
    }
    if (!_pointerArray) {
        _pointerArray = [NSPointerArray weakObjectsPointerArray];
    }
    if (!_mapTable) {
        _mapTable = [[NSMapTable alloc]initWithKeyOptions:(NSPointerFunctionsWeakMemory) valueOptions:(NSPointerFunctionsWeakMemory) capacity:10];
    }
}

#pragma mark - Api

+ (void)registObserver:(id<TestServiceProtocol>)observer type:(TestServiceWeakType)type {
    
    switch (type) {
        case TestServiceWeakTypeNSValue:
        {
            [self registObserverByValue:observer];
        }
            break;
        case TestServiceWeakTypeNSBlock:
        {
            [self registObserverByBlock:observer];
        }
            break;
        case TestServiceWeakTypeNSPointerArray:
        {
            [self registObserverByPointer:observer];
        }
            break;
        case TestServiceWeakTypeNSHashTable:
        {
            [self registObserverByHash:observer];
        }
            break;
        case TestServiceWeakTypeNSMapTable:
        {
            [self registObserverByMap:observer];
        }
            break;
        default:
            break;
    }
}

#pragma mark -

+ (void)registObserverByHash:(id<TestServiceProtocol>)observer {
    if (observer) {
        [[TestDemoService service].hashTable addObject:observer];
    }
}

+ (void)registObserverByBlock:(id<TestServiceProtocol>)observer {
    
    // weak obj by block
    __weak id weakObj = observer;
    WeakObjBlock weakBlock = ^{
        return weakObj;
    };
    
    [[TestDemoService service].weakBlockArr addObject:weakBlock];
}

+ (void)registObserverByValue:(id<TestServiceProtocol>)observer {
    NSValue *weakValue = [NSValue valueWithNonretainedObject:observer];
    [[TestDemoService service].weakValueArr addObject:weakValue];
}

+ (void)registObserverByPointer:(id<TestServiceProtocol>)observer {
    
    [[TestDemoService service].pointerArray addPointer:(__bridge void * _Nullable)(observer)];
}

+ (void)registObserverByMap:(id<TestServiceProtocol>)observer {
    
    [[TestDemoService service].mapTable setObject:observer forKey:@([TestDemoService service].mapTable.count)];
}

#pragma mark - Task

+ (void)startAllTasks {
    [self startWeakBlockTask];
    [self startWeakValueTask];
    [self startPointerArrayTask];
    [self startHashTableTask];
    [self startMapTableTask];
}

#pragma mark -

+ (void)startWeakBlockTask {
    
    for (WeakObjBlock block in [TestDemoService service].weakBlockArr) {
        id delegate = nil;
        if (block) {
            delegate = block();
        }
        if ([delegate respondsToSelector:@selector(testService:type:)]) {
            [delegate testService:[TestDemoService service] type:TestServiceWeakTypeNSBlock];
        }
    }
}

+ (void)startWeakValueTask {
    
    for (NSValue *weakValue in [TestDemoService service].weakValueArr) {
        
        id delegate = weakValue.nonretainedObjectValue;
        if ([delegate respondsToSelector:@selector(testService:type:)]) {
            [delegate testService:[TestDemoService service] type:TestServiceWeakTypeNSValue];
        }
    }
}

+ (void)startPointerArrayTask {
    
    NSMutableArray *shouldRemovedIndexArr = [NSMutableArray new];
    NSUInteger idx = 0;
    for (id wkDelegate in [TestDemoService service].pointerArray) {
        if (wkDelegate && [wkDelegate respondsToSelector:@selector(testService:type:)]) {
            [wkDelegate testService:[TestDemoService service] type:(TestServiceWeakTypeNSPointerArray)];
        }else {
            [shouldRemovedIndexArr addObject:@(idx)];
        }
        idx++;
    }
    [shouldRemovedIndexArr enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[TestDemoService service].pointerArray removePointerAtIndex:idx];
    }];
}

+ (void)startHashTableTask {
    
    for (id object in [TestDemoService service].hashTable) {
        if ([object respondsToSelector:@selector(testService:type:)]) {
            [object testService:[TestDemoService service] type:TestServiceWeakTypeNSHashTable];
        }
    }
}

+ (void)startMapTableTask {
    
    NSMutableArray *shouldRemovedIndexArr = [NSMutableArray new];
    for (int i = 0; i < [TestDemoService service].mapTable.count; i++) {
        id delegate = [[TestDemoService service].mapTable objectForKey:@(i)];
        if (delegate && [delegate respondsToSelector:@selector(testService:type:)]) {
            [delegate testService:[TestDemoService service] type:(TestServiceWeakTypeNSMapTable)];
        }else {
            [shouldRemovedIndexArr addObject:@(i)];
        }
    }
    [shouldRemovedIndexArr enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[TestDemoService service].mapTable removeObjectForKey:obj];
    }];
}

@end
