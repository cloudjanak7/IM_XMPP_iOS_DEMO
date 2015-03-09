//
//  NSMutableDictionary+CH.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/4.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "NSMutableDictionary+CH.h"

@implementation NSMutableDictionary (CH)

- (void)cleanEmptyKey
{
    NSMutableSet *cleanSet = [NSMutableSet set];
    for (id Obj in self.allKeys) {
        if (self[Obj] == nil)
        {
            [cleanSet addObject:Obj];
        }
    }
    
    for (id Obj in cleanSet)
    {
        [self removeObjectForKey:Obj];
    }
}

@end
