//
//  NSDate+SCH.h
//  微博
//
//  Created by 孙晨辉 on 15/1/12.
//  Copyright (c) 2015年 孙晨辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SCH)

//是否为今天
- (BOOL)isToday;

//是否为昨天
- (BOOL)isYesterday;

//是否为今年
- (BOOL)isThisYear;

- (NSDate *)dateWithYMD;

//获得与当前时间的差距
- (NSDateComponents *)daltaWithNow;

@end
