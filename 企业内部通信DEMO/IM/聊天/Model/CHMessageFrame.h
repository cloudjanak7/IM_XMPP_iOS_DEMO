//
//  CHMessageFrame.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 15/3/6.
//  Copyright (c) 2015年 东华创元. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageObject;
@interface CHMessageFrame : NSObject

/** 单条消息对象 */
@property (nonatomic, strong) MessageObject *msgObj;

/** 消息button Size */
@property (nonatomic, assign, readonly) CGSize msgS;

/** cell的高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;

+ (instancetype)messageFrameWithXMPPMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message;

@end
