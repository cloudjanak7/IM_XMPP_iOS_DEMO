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

@interface ChatMessageCell ()
{
    UIImage *_receiveImage;
    UIImage *_receiveImageHL;
    UIImage *_senderImage;
    UIImage *_senderImageHL;
    
    AVAudioPlayer *_player;
}

@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageWidthConstraint;
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
    
    [cell setMessageFrame:msgF isOutgoing:msgObj.isOutgoing];
    cell.timeStampLabel.text = msgObj.timeStampStr;
    
    return cell;
}

- (UIImage *)stretcheImage:(UIImage *)img
{
    return [img stretchableImageWithLeftCapWidth:img.size.width * 0.5 topCapHeight:img.size.height * 0.6];
}

- (void)awakeFromNib
{
    _receiveImage = [UIImage imageNamed:@"ReceiverTextNodeBkg"];
    _receiveImageHL = [UIImage imageNamed:@"ReceiverTextNodeBkgHL"];
    _senderImage = [UIImage imageNamed:@"SenderTextNodeBkg"];
    _senderImageHL = [UIImage imageNamed:@"SenderTextNodeBkgHL"];
    
    //处理图像拉伸(因为iOS 6不支持图像切片)
    _receiveImage = [self stretcheImage:_receiveImage];
    _receiveImageHL = [self stretcheImage:_receiveImageHL];
    _senderImageHL = [self stretcheImage:_senderImageHL];
    _senderImage = [self stretcheImage:_senderImage];
}

- (void)setMessageFrame:(CHMessageFrame *)msgF isOutgoing:(BOOL)isOutgoing
{
    if (isOutgoing)
    {
        [_messageButton setBackgroundImage:_senderImage forState:UIControlStateNormal];
        [_messageButton setBackgroundImage:_senderImageHL forState:UIControlStateHighlighted];
    }
    else
    {
        [_messageButton setBackgroundImage:_receiveImage forState:UIControlStateNormal];
        [_messageButton setBackgroundImage:_receiveImageHL forState:UIControlStateHighlighted];
    }
    
    _messageHeightConstraint.constant = msgF.msgS.height + 30.0;
    _messageWidthConstraint.constant = msgF.msgS.width + 30.0;
    
    switch (msgF.msgObj.messageType)
    {
        case MessageTypeImage:
            [_messageButton setImage:msgF.msgObj.image forState:UIControlStateNormal];
            break;
        case MessageTypeRecord:
            [_messageButton setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying003"] forState:UIControlStateNormal];
            break;
        case MessageTypeText:
            [_messageButton setTitle:msgF.msgObj.messageText forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    //2.4重新调整布局
    [self setNeedsDisplay];
}

@end
