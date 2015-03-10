//
//  RelateMessage.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/6.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "RelateMessage.h"
#import "NSDate+SCH.h"


@implementation RelateMessage
@synthesize timeStampStr = _timeStampStr;

@dynamic bareJidStr;
@dynamic body;
@dynamic streamBareJidStr;
@dynamic bareJidPhoto;
@dynamic timestamp;

- (NSString *)timeStampStr
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"EEE MMM dd HH:mm:ss";
    if (self.timestamp.isToday)
    {
        if (self.timestamp.daltaWithNow.hour >= 1)
        {
            format.dateFormat = @"HH:mm";
            return [format stringFromDate:self.timestamp];
        }
        return @"刚刚";
    }
    else if (self.timestamp.isYesterday)
    {
        format.dateFormat = @"昨天 HH:mm";
        return [format stringFromDate:self.timestamp];
    }
    else if (self.timestamp.isThisYear)
    {
        format.dateFormat = @"MM-dd HH:mm";
        return [format stringFromDate:self.timestamp];
    }
    else
    {
        format.dateFormat = @"yyyy-MM-dd HH:mm";
        return [format stringFromDate:self.timestamp];
    }
}

@end
