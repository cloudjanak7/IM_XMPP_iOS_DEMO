//
//  ChatMessageCell.h
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/20.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CHMessageFrame;
@interface ChatMessageCell : UITableViewCell

/** 消息frame */
@property (nonatomic, strong) CHMessageFrame *msgF;



//- (void)setMessage:(MessageObject *)msgObj isOutgoing:(BOOL)isOutgoing;

/** 初始化一个cell */
+ (instancetype)cellForTableView:(UITableView *)tableView withMessageFrame:(CHMessageFrame *)msgF myImage:(UIImage *)myImage bareImage:(UIImage *)bareImage;

@end
