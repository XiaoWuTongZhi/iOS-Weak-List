//
//  Person.m
//  TestHash
//
//  Created by wyh on 2018/9/20.
//  Copyright © 2018年 wyh. All rights reserved.
//

#import "Person.h"

@interface Person ()



@end

@implementation Person

- (id)copyWithZone:(NSZone *)zone {
    Person *person = [[Person alloc]init];
    person.name = person.name;
    person.birthday = person.birthday;
    return person;
}

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[Person class]]) {
        return NO;
    }
    if ([[(Person *)object name] isEqual:self.name]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    NSUInteger hashCount = [_name hash] ^ [_birthday hash];
    NSLog(@"hash:%ld",hashCount);
    return  hashCount;
}

- (NSString *)description {
    NSLog(@"desc:%@",[super description]);
     return [super description];
}

@end
