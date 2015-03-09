//
//  NSMutableDictionary+CH.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/4.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (CH)

/** 清除字典中键值对应的对象为空的关键字 */
- (void)cleanEmptyKey;

@end
