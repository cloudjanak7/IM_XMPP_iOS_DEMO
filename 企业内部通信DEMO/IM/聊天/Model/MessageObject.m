//
//  MessageObject.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/26.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "MessageObject.h"
#import "NSDate+SCH.h"


@implementation MessageObject

- (id)init
{
    self = [super init];
    _fileName = @"";
    _fileSize = 0;
    _recordTime = 0;
    _messageText = @"";
    _messageType = 0;
    _fileDataStr = @"";
    return self;
}

- (NSString *)timeStampStr
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"EEE MMM dd HH:mm:ss";
    if (_timeStamp.isToday)
    {
        if (_timeStamp.daltaWithNow.hour >= 1)
        {
            format.dateFormat = @"HH:mm";
            return [format stringFromDate:_timeStamp];
        }
        return @"";
    }
    else if (_timeStamp.isYesterday)
    {
        format.dateFormat = @"昨天 HH:mm";
        return [format stringFromDate:_timeStamp];
    }
    else if (_timeStamp.isThisYear)
    {
        format.dateFormat = @"MM-dd HH:mm";
        return [format stringFromDate:_timeStamp];
    }
    else
    {
        format.dateFormat = @"yyyy-MM-dd HH:mm";
        return [format stringFromDate:_timeStamp];
    }
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [dictM setValue:_fileDataStr forKey:kFileData];
    [dictM setValue:[NSNumber numberWithInt:_messageType] forKey:kMessageType];
    [dictM setValue:_fileName forKey:kFileName];
    [dictM setValue:[NSNumber numberWithInteger:_recordTime] forKey:kRecordTime];
    [dictM setValue:[NSNumber numberWithInteger:_fileSize] forKey:kFileSize];
    [dictM setValue:_messageText forKey:kMessageText];
    return dictM;
}

@end
