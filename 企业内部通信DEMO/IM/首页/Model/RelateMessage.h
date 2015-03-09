//
//  RelateMessage.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/6.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RelateMessage : NSManagedObject

@property (nonatomic, retain) NSString * bareJidStr;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * streamBareJidStr;
@property (nonatomic, retain) NSData * bareJidPhoto;
@property (nonatomic, retain) NSDate * timestamp;

/** 时间戳 */
@property (nonatomic, strong, readonly) NSString *timeStampStr;

@end
