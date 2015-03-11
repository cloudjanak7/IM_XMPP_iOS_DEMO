//
//  MessageObject.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/26.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+XMPP.h"

#define kFileName @"fileName"
#define kFileData @"fileDataStr"
#define kFileSize @"fileSize"
#define kRecordTime @"recordTime"
#define kMessageType @"messageType"
#define kMessageText @"messageText"

typedef enum
{
    MessageTypeText = 0,
    MessageTypeRecord,
    MessageTypeImage
} MessageType;

#define ChatMessageImageSize CGSizeMake(112, 100)

@interface MessageObject : NSObject

/** 文件名 */
@property (nonatomic, strong) NSString *fileName;//文件名
/** 文件内容 */
@property (nonatomic, strong) NSString *fileDataStr;//文件内容
/** 文件大小 */
@property (nonatomic, assign) NSInteger fileSize;//文件大小
/** 录音时长 */
@property (nonatomic, assign) NSInteger recordTime;//录音时长
/** 消息类型 */
@property (nonatomic, assign) MessageType messageType;//消息类型
/** 文本消息 */
@property (nonatomic, strong) NSString *messageText;//文本消息

///** 文件数据 */
//@property (nonatomic, strong) NSData *fileData;
/** 录音文本显示 */
@property (nonatomic, copy) NSString *recordText;
/** 发送方 */
@property (nonatomic, assign) BOOL isOutgoing;
/** 消息的时间 */
@property (nonatomic, strong) NSDate *timeStamp;
/** 时间戳 */
@property (nonatomic, strong, readonly) NSString *timeStampStr;
/** 图片 */
@property (nonatomic, strong) UIImage *image;


- (NSDictionary *)toDictionary;


@end
