//
//  CHMessageFrame.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/6.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import "CHMessageFrame.h"
#import "MessageObject.h"
#import "UIImage+CH.h"

@implementation CHMessageFrame

+ (instancetype)messageFrameWithXMPPMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message
{
    CHMessageFrame *msgF = [[CHMessageFrame alloc] init];
    MessageObject *msgObj = [CHMessageFrame jsonToMessageObject:message.body];
    msgObj.isOutgoing = message.isOutgoing;
    msgObj.timeStamp = message.timestamp;
    msgF.msgObj = msgObj;
    return msgF;
}

- (void)setMsgObj:(MessageObject *)msgObj
{
    _msgObj = msgObj;
    
    switch (msgObj.messageType)
    {
        case MessageTypeImage:
            _msgS = [self cellForImageMessage:msgObj];
            break;
        case MessageTypeRecord:
            _msgS = [self cellForRecordMessage:msgObj];
            break;
        case MessageTypeText:
            _msgS = [self cellForTextMessage:msgObj.messageText];
            break;
        default:
            break;
    }
    
    CGSize size = CGSizeZero;
    if (msgObj.messageType == MessageTypeText)
    {
        size = [msgObj.messageText sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, MAXFLOAT)];
    }
    if (msgObj.messageType == MessageTypeImage)
    {
        size = _msgS;
    }
    if (size.height + 50.0 > 80.0)
    {
        _cellHeight = size.height + 50.0;
    }
    else
    {
        _cellHeight = 80;
    }
}

#pragma mark - private
/** 文本消息 */
- (CGSize)cellForTextMessage:(NSString *)message
{
    //2.1计算文字占用的区间
    return [message sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(180, MAXFLOAT)];
}

/** 图片消息 */
- (CGSize)cellForImageMessage:(MessageObject *)msgObj
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:msgObj.fileDataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    msgObj.image = [UIImage imageWithData:data];
    return [msgObj.image imageSizeReturnByScallingAspectToMaxSize:ChatMessageImageSize];
}

/** 录音消息 */
- (CGSize)cellForRecordMessage:(MessageObject *)msgObj
{
    _msgObj.recordText = [NSString stringWithFormat:@"     %u \"     ", (unsigned int)msgObj.recordTime];
    CGSize textSize = [self cellForTextMessage:_msgObj.recordText];
    UIImage *image = [UIImage imageNamed:@"SenderVoiceNodePlaying003"];
    CGFloat width = textSize.width + image.size.width;
    CGFloat height = textSize.height > image.size.width ? textSize.height : image.size.width;
    return CGSizeMake(width, height);
}

#pragma mark json转模型
+ (MessageObject *)jsonToMessageObject:(NSString *)jsonStr
{
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    MessageObject *msgObj = [MessageObject objectWithKeyValues:dict];
    return msgObj;
}

@end
