//
//  ChatMessageCell.m
//  企业内部通信DEMO
//
//  Created by 孙晨辉 on 14/11/20.
//  Copyright (c) 2014年 东华创元. All rights reserved.
//

#import "ChatMessageCell.h"
#import "SoundTool.h"
#import "UIImage+CH.h"
#import "CHMessageFrame.h"
#import "MessageObject.h"
#import "CHMessageView.h"

@interface ChatMessageCell ()
{
    AVAudioPlayer *_player;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnWidthConstraint;
@property (nonatomic, weak) IBOutlet UILabel *recordTimeLabel;
@property (strong, nonatomic) IBOutlet CHMessageView *messageButton;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
/** 时间戳 */
@property (nonatomic, weak) IBOutlet UILabel *timeStampLabel;

@end

@implementation ChatMessageCell

+ (instancetype)cellForTableView:(UITableView *)tableView withMessageFrame:(CHMessageFrame *)msgF myImage:(UIImage *)myImage bareImage:(UIImage *)bareImage
{
    static NSString *FromID = @"ChatFromCell";
    static NSString *ToID = @"ChatToCell";

    MessageObject *msgObj = msgF.msgObj;
    
    ChatMessageCell *cell = nil;
    if (msgObj.isOutgoing)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ToID];
        if (myImage)
        {
            cell.headImageView.image = myImage;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:FromID];
        if (bareImage)
        {
            cell.headImageView.image = bareImage;
        }
    }
    
    if (msgObj.messageType == MessageTypeRecord)
    {
        cell.recordTimeLabel.hidden = NO;
    }
    else
    {
        cell.recordTimeLabel.hidden = YES;
    }
    
    cell.messageButton.msgF = msgF;
    cell.messageButton.autoresizesSubviews = NO;
    cell.btnHeightConstraint.constant = msgF.msgS.height + 30;
    cell.btnWidthConstraint.constant = msgF.msgS.width + 30;
    
    cell.timeStampLabel.text = msgObj.timeStampStr;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ChatBackgroundThumb_00.jpg"]];
    
    return cell;
}

@end
